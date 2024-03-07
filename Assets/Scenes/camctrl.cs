using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class camctrl : MonoBehaviour
{
    private void Awake()
    {
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
    }
}
