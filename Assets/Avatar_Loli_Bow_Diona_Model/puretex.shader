Shader "Unlit/puretex"
{
    Properties
    {
        _MainTex ("maintex", 2D) = "white" {}
        _ShadowTone("shadowtone",range(0,1))=0.5
        _ShadowBias("shadowbias",range(-0.005,0.005))=0
        _SelfShadowThreshold("selfshadowthreshold",range(-2,2))=0
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
            float4 _gShadowMapTexture_TexelSize;
            float4x4 _gWorldToShadow;
            float _ShadowTone;
            float _ShadowBias;
            float _SelfShadowThreshold;

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

            // float PCFSample(float depth,float2 uv)
            // {
            //     float shadow=0.0;
            //     for(int x=-1;x<=1;++x)
            //     {
            //         for(int y=-1;y<=1;++y)
            //         {
            //             float4 col=tex2D(_gShadowMapTexture,uv+float2(x,y)*_gShadowMapTexture_TexelSize.xy);
            //             float sampleDepth=DecodeFloatRGBA(col);
            //             shadow+=(sampleDepth+_ShadowBias)<depth?_gShadowStrength : 1 ;
            //         }
            //     }
            //     return shadow/9;
            // } 
            float PCF(float depth,float2 uv)
            {
                float shadow=0;
                for(int x=-1;x<=1;x++)
                {
                    for(int y=-1;y<=1;y++)
                    {
                        float shadowdepth=SAMPLE_DEPTH_TEXTURE(_gShadowMapTexture,uv+float2(x,y)*_gShadowMapTexture_TexelSize.xy);
                        shadow=shadow+(shadowdepth<(depth+_ShadowBias));
                    }
                }
                return shadow/9;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                //return i.shadowcoord;
                float4 maintex=tex2D(_MainTex,i.uv);
                float2 shadowuv=i.shadowcoord.xy/i.shadowcoord.w;
                shadowuv=shadowuv*0.5+0.5;
                float depth=i.shadowcoord.z/i.shadowcoord.w;
                //depth=1-depth;
                float shadowmap=SAMPLE_DEPTH_TEXTURE(_gShadowMapTexture,shadowuv);
                //return shadowmap;
                 float shadowstate=shadowmap<(depth+_ShadowBias);//+_SelfShadowThreshold;
                //return shadowstate;
                
                //float shadow=
                float shadow=PCF(depth,shadowuv);
                return shadow;
                float4 finalcolor=lerp(_ShadowTone,1,shadow)*maintex;
                return finalcolor;
                return shadow;
            }
            ENDCG
        }
    }
}
