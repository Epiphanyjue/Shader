using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class SDF : EditorWindow
{
    public Texture2D sourceTex;
    private static SDF window;
    private SerializedObject mSerObj;
    private SerializedProperty mSerProperty;

    [MenuItem("Tools/距离场图像生成")]

    private static void CreateSDF()
    {
        window=EditorWindow.GetWindow<SDF>("距离场贴图生成器");
        window.Show();
        window.minSize=new Vector2(200,300);
    }
    private void OnEnable() 
    {
        mSerObj=new SerializedObject(this);
        mSerProperty=mSerObj.FindProperty("sourceTex");    
    }

    private void DrawTextureProperties()
    {
        EditorGUILayout.BeginVertical();
        EditorGUILayout.LabelField("源图像");
        EditorGUILayout.PropertyField(mSerProperty,true);
        EditorGUILayout.PasswordField("输入密码","114514");
        //EditorGUILayout.LayerField("选择",3);
        EditorGUILayout.EndVertical();
        mSerObj.ApplyModifiedProperties();
    }

    private void ComputeSDF()
    {
        if(GUILayout.Button("创建贴图并保存"))
        {

        }
    }
    private void OnGUI()
    {
        DrawTextureProperties();
        ComputeSDF();
    }
}
