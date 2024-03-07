using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SelfShadowCamera : MonoBehaviour
{
    private Camera lightcamera;
    public Shader depthcamerashader;
    // Start is called before the first frame update
    void Start()
    {
        lightcamera=GetComponent<Camera>();
        lightcamera.targetTexture=Create2DTexture(2048);
    }

    void Update()
    {
        Matrix4x4 pmatrix=GL.GetGPUProjectionMatrix(lightcamera.projectionMatrix, false);
        Shader.SetGlobalMatrix("_EyeWorldToShadow",pmatrix*lightcamera.worldToCameraMatrix);
        lightcamera.RenderWithShader(depthcamerashader,"");
    }

    private RenderTexture Create2DTexture(int mapsize)
    {
        RenderTexture shadowmap = new RenderTexture(mapsize, mapsize, 24, RenderTextureFormat.Depth);
        Shader.SetGlobalTexture("_EyeShadowMap", shadowmap);
        return shadowmap;
    }
}
