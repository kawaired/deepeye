Shader "Unlit/shadowreceivetest"
{
    Properties
    {
        _ShadowBias("shadowbias",range(-0.001,0.001))=0
        _TestNum("testnum",range(1,20))=1
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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 shadowcoord:Texcoord0;
                float normalfac:Texcoord1;
                float4 clipvertex:Texcoord2;
            };

           sampler2D _gShadowMapTexture;
           float4 _gShadowMapTexture_ST;
           float4x4 _gWorldToShadow;
           float _ShadowBias;
           float _TestNum;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float4 worldvertex=mul(unity_ObjectToWorld,v.vertex);
                o.clipvertex=UnityObjectToClipPos(v.vertex);
                float3 worldnormal=UnityObjectToWorldNormal(v.normal);
                o.normalfac=dot(_WorldSpaceLightPos0,normalize(worldnormal))>0.2;
                o.shadowcoord=mul(_gWorldToShadow,worldvertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //return float4(0.2,0.4,0.9,1);
                //return i.clipvertex.z>0;
                //return i.shadowcoord.z/_TestNum;
                //return i.clipvertex.z/i.clipvertex.w;
                float2 shadowuv=i.shadowcoord.xy/i.shadowcoord.w;
                shadowuv=shadowuv*0.5+0.5;
                float depth=i.shadowcoord.z/i.shadowcoord.w;
                float4 shadowmap=SAMPLE_DEPTH_TEXTURE(_gShadowMapTexture,shadowuv);
                 return shadowmap.x<depth+_ShadowBias;
                // float sampledepth=DecodeFloatRGBA(shadowmap);
                // return sampledepth;
                // return (sampledepth<(depth+_ShadowBias))*i.normalfac+(1-i.normalfac);
            }
            ENDCG
        }
    }
}
