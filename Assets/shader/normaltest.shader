Shader "Unlit/normaltest"
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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldnormal:TEXCOORD3;
                float3 viewdir:TEXCOORD1;
                float3 lightdir:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldnormal=UnityObjectToWorldNormal(v.normal);
                float3 worldvertex=mul(unity_ObjectToWorld,v.vertex);
                o.viewdir=normalize(_WorldSpaceCameraPos-worldvertex);
                o.lightdir=normalize(_WorldSpaceLightPos0-worldvertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //return normalize(i.worldnormal).xyzz;
                float fresnel=dot(i.worldnormal,i.lightdir);
                //return 
                return  i.worldnormal.xyzz*(-1)*fresnel;//+i.viewdir.xyzz;
                return fresnel;
            }
            ENDCG
        }
    }
}
