Shader "Unlit/normaleye"
{
    Properties
    {
        _ShadowLightDir("shadowlightdir",color)=(1,1,1,1)
        _ShadowBiasx("shadowbiasx",range(0,1))=0
        _ShadowBiasy("shadowbiasy",range(-1,1))=0
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
                float3 normal:NORMAL;

            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            float4 _ShadowLightDir;
            float _ShadowBiasx;
            float _ShadowBiasy;

            v2f vert (appdata v)
            {
                v2f o;
                float3 worldnormal=(UnityObjectToWorldDir(v.normal));
                float lightshadowfactor=(1-saturate(dot(normalize(_ShadowLightDir.xyz),worldnormal)))*_ShadowBiasy;
                float3 worldvertex=mul(unity_ObjectToWorld,v.vertex);
                o.vertex=UnityWorldToClipPos(worldvertex+lightshadowfactor*worldnormal);
                //o.vertex = UnityObjectToClipPos(v.vertex);
                //o.vertex.z=max(o.vertex.z+_ShadowBiasx,-o.vertex.w);
                o.vertex.z=o.vertex.z+_ShadowBiasx;
                // UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //return -i.vertex.w;
                return 1-i.vertex.z;
            }
            ENDCG
        }
    }
}
