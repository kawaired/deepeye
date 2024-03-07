Shader "Unlit/showdepth"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 shadowcoord:Texcoord1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _gShadowMapTexture;
            float4 _gShadowMapTexture_ST;
            float4x4 _gWorldToShadow;
            sampler2D _EyeShadowMap;
            float4 _EyeShadowMap_ST;
            float4 _EyeShadowMap_TexelSize;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                float4 worldvertex=mul(unity_ObjectToWorld,v.vertex);
                 o.shadowcoord=mul(_gWorldToShadow,worldvertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float2 shadowuv=i.shadowcoord.xy/i.shadowcoord.w;
                shadowuv=shadowuv*0.5+0.5;
                //return SAMPLE_DEPTH_TEXTURE(_gShadowMapTexture,i.uv);
                float4 shadowmap=SAMPLE_DEPTH_TEXTURE(_EyeShadowMap,i.uv);
                //return float4(1,1,1,1);
                return shadowmap.xxxx;
                float sampledepth=DecodeFloatRGBA(shadowmap);
                return sampledepth;
            }
            ENDCG
        }
    }
}
