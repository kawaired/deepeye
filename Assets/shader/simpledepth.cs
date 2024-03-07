using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class simpledepth : MonoBehaviour
{
    private Camera lightcamera;
    private int shadowmid=2;
    public Shader depthcamerashader;

    // Start is called before the first frame update
    void Start()
    {
        lightcamera=GetComponent<Camera>();
        lightcamera.targetTexture=Create2DTexture(shadowmid);
        //lightcamera.SetReplacementShader(depthcamerashader,"");
    }

    // Update is called once per frame
    void Update()
    {
        Matrix4x4 pmatrix=GL.GetGPUProjectionMatrix(lightcamera.projectionMatrix, false);
        Shader.SetGlobalMatrix("_gWorldToShadow",pmatrix*lightcamera.worldToCameraMatrix);
        lightcamera.RenderWithShader(depthcamerashader,"");
    }

     private RenderTexture Create2DTexture(int shadowResolution)
    {
        RenderTexture shadowmap = new RenderTexture(512 * shadowResolution, 256 * shadowResolution, 24, RenderTextureFormat.Depth);
        //shadowmap.filterMode=FilterMode.Point;
        //ShadowMap.hideFlags = HideFlags.DontSave;
        Shader.SetGlobalTexture("_gShadowMapTexture", shadowmap);
        //Shader.SetGlobalFloat("_gShadowBias",-0.0000005f);
        //Transform
        //Camera
        return shadowmap;
    }
}
