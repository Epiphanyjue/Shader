Shader "CRLuo/CRLuo_CFX_ND_PenLine"
{
Properties
    {
        _MainTex ("需要处理的图像", 2D) = "White" {}
        _BaseColor("底部颜色",Color)=(0.4,0.6,0.7,1)
        _BaseRange("基础色范围",Range(0,10))=0
        _BaseOffset("基础色偏移",Range(0,10))=1
        _BrightColor("亮色",Color)=(1,1,1,1)
        _DarkColor("暗色",Color)=(0,0.75,1,1)
        _DarkRange("暗色范围",Range(0,1))=0.5
        _PenColor("钢笔颜色",Color)=(0,1,1,1)
        _PenRange("钢笔范围欸",Range(0,10))=5
        _PenOffset("钢笔范围欸",Range(0,10))=2
		_InLineColor("内描边颜色",Color)=(0,0,0,1)
		_InNorWidth("内描边宽度",Range(0,1))=0.055
		_InNorOffset("内描边限制",Range(0,1))=0.05
        _OutLineColor("外描边颜色",Color)=(0,0,0,1)
		_OutDepWidth("外描边宽度",Range(0,1))=0.055
		_OutDepOffset("外描边偏移",Range(0,1))=0.05
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {

			//引入程序使用的函数集
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

			//获取场景模型数据
            struct appdata
            {
				//获取模型顶点数据
                float4 vertex : POSITION;
				//获取模型UV数据
                float2 uv : TEXCOORD0;
            };


			//定义顶点片段着色器数据类型
            struct v2f
            {
				//UV数据
                float2 uv : TEXCOORD0;
				//顶点数据
                float4 vertex : SV_POSITION;
                float4 scrPos:TEXCOORD1;
            };



			//载入材质球主贴图
            sampler2D _MainTex;

			//深度预渲染
			sampler2D  _CameraDepthTexture;
			//法线预渲染
			sampler2D _CameraNormalsTexture;

             sampler2D  _CameraDepthNormalsTexture;     //获得深度和法线



            float4 _BaseColor;
            float _BaseRange;
            float _BaseOffset;
            float4 _BrightColor;
            float4 _DarkColor;
            float _DarkRange;
            float4 _PenColor;
            float _PenRange;
            float _PenOffset;
            
            float4 _InLineColor;
		    float _InNorWidth;
		    float _InNorOffset;
            float4 _OutLineColor;
		    float _OutDepWidth;
		    float _OutDepOffset;


			//顶点片段着色器程序
            v2f vert (appdata v)
            {
				//定义输出数据
                v2f o;
				//顶点转换为摄像机视角坐标
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.scrPos=ComputeScreenPos(o.vertex);
				//应用贴图的偏移与重复
                o.uv = v.uv;
				//输出模型结果
                return o;
            }


			//表面着色器程序
            fixed4 frag (v2f i) : SV_Target
            {
                float D =DecodeFloatRG( tex2D(_CameraDepthNormalsTexture, i.uv).zw);

            	_OutDepWidth *= 0.01;
                float CDT0 = DecodeFloatRG( tex2D(_CameraDepthNormalsTexture, i.uv+float2(-_OutDepWidth,-_OutDepWidth)).zw);
				float CDT1 = DecodeFloatRG( tex2D(_CameraDepthNormalsTexture, i.uv+float2(_OutDepWidth,_OutDepWidth)).zw);
       			float CDT2 = DecodeFloatRG( tex2D(_CameraDepthNormalsTexture, i.uv+float2(-_OutDepWidth,_OutDepWidth)).zw);
				float CDT3 = DecodeFloatRG( tex2D(_CameraDepthNormalsTexture, i.uv+float2(_OutDepWidth,-_OutDepWidth)).zw);

                float DLine = abs(CDT0-CDT1)+abs(CDT2-CDT3)-pow(D,3)>_OutDepOffset?1:0;
                
                _InNorWidth*=0.01;
                 float3 CNT0 = DecodeViewNormalStereo(tex2D(_CameraDepthNormalsTexture, i.uv+float2(-_InNorWidth,-_InNorWidth)));
                 float3 CNT1 = DecodeViewNormalStereo(tex2D(_CameraDepthNormalsTexture, i.uv+float2(_InNorWidth,_InNorWidth)));
                 float3 CNT2 = DecodeViewNormalStereo(tex2D(_CameraDepthNormalsTexture, i.uv+float2(-_InNorWidth,_InNorWidth)));
                 float3 CNT3 = DecodeViewNormalStereo(tex2D(_CameraDepthNormalsTexture, i.uv+float2(_InNorWidth,-_InNorWidth)));

                float3 CNT =  abs(CNT0-CNT1)+abs(CNT2-CNT3);

                float NLine =CNT.r+CNT.g-D*10>_InNorOffset?1:0;

                float4 Tex = tex2D(_MainTex, i.uv);

                float gray = dot(Tex.rgb, float3(0.299, 0.587, 0.114));

                float3 TexLine =fwidth(Tex.rgb);



                 float4 Col = float4(_BaseColor.rgb,Tex.a);

                 Col.rgb = lerp( _BrightColor.rgb,_DarkColor.rgb,step(gray,_DarkRange)*_DarkColor.a*(1-D));

                 Col.rgb = lerp( Col.rgb,_PenColor.rgb,pow(saturate((TexLine.r+TexLine.g+TexLine.b)*_PenRange),_PenOffset)*_PenColor.a);

                 Col.rgb = lerp( Col.rgb,_BaseColor,saturate(pow(5*D+_BaseRange,_BaseOffset)));

                 Col.rgb = lerp( Col.rgb,_InLineColor.rgb,NLine*_InLineColor.a);

                 Col.rgb = lerp( Col.rgb,_OutLineColor.rgb,DLine*_OutLineColor.a);


				//输出贴图结果
                return   Col;
            }
            ENDCG
        }
    }

}