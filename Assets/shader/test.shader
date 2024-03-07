Shader "Unlit/test"
{
    Properties
    {
        _MainTex ("maintex", 2D) = "white" {}
        _NormalTex("normaltex",2D)="white"{}
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
                float4 color:COLOR;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal:NORMAL;
                float3 tangent:TANGENT;
                float3 sidenormal:TEXCOORD1;
                float4 color:COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalTex;
            float4 _NormalTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color=v.color;
                o.normal=v.normal;
                o.tangent=v.tangent;
                o.sidenormal=cross(v.normal,v.tangent);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normalcolor=tex2D(_NormalTex,i.uv)*2-float3(1,1,1);
                return i.normal.xyzz;
                float3 cusnormal=normalize(i.tangent*normalcolor.x+i.sidenormal*normalcolor.y+i.normal*normalcolor.z);
                return cusnormal.xyzz;
            }
            ENDCG
        }
    }
}
