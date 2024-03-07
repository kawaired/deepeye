Shader "Unlit/hair"
{
    Properties
    {
        _MainTex ("maintex", 2D) = "white" {}
        _NormalTex("normaltex",2D)="white"{}
        _PropertyTex("propertytex",2D)="white"{}
        _MaskTex("masktex",2D)="white"{}
        _ShadowRampTex("shadowramptex",2D)="white"{}
        _MatTex("matex",2D)="white"{}
        _MatRampTex("matramptex",2D)="white"{}
        _RefectionTex("refectiontex",2D)="white"{}

        _MainColor("maincolor",color)=(0.4,0,0.5,1)
        _MatColor("matcolor",color)=(0.3,0.1,0.4,1)
        _ReflectColor("reflectcolor",color)=(0.4,0.3,0.8,1)
        _EmissionColor("emissioncolor",color)=(0.2,0.2,0.2,0.2)
        _FillInner("fillinner",color)=(1,1,1,1)
        _FillOuter("fillouter",color)=(0,0,0,0)
        _FillClamp("fillcamp",range(-0.5,0.5))=0

        _ZOffset("zoffset",range(-1,1))=0
        _MatScale("matscale",range(0,2))=1
        _ReflectScale("reflectscale",range(0,2))=1

        _RimLightThreshold("rimlightthreshold",range(0,5))=1
        _RimLightFade("rimlightfade",range(0,5))=1
        _RimLightRange("rimlightrange",range(0,1))=1
        _RimLightDir1("rimlightdir1",float)=(0.2,0.2,0.2)
        _RimLightDir2("rimlightdir2",float)=(0.4,0.4,0.4)
        _RimLightColor("_rimlightcolor",color)=(0.2,0.2,0.2,0.2)

        _SimAddLightPos("simaddlightpos",color)=(0.2,0.2,0.2,0.2)
        _SimAddLightColor("simaddlightcolor",color)=(0.3,0.3,0.3,0.3)
        _SimAddLightAttenuation("simaddlightattenuation",color)=(0.4,0.4,0.4,0.4)
        _ProbeLightBase("probelightbase",color)=(0.5,0.5,0.5,0.5)
        _ProbeScale("probescale",range(0,2))=1
        _LightIndicesOffsetAndCount("lightindicesoffsetandcount",range(-1,1))=0
        _Unity4LightIndices0("unity4lightindices0",float)=(0,0,0,0)
        _NormalScale("normalscale",range(0,2))=1
        _SimShadowLightDir("simshadowlightdir",color)=(0.3,0.3,0.3,0.3)
        _ShadowMaskScale("shadowmaskscale",range(-5,5))=1
        

        _SpecularThreshold("specularthreshold",range(0.01,1))=1
        _SpecularFade("specularfade",range(0.01,1))=1
        _SpecularColor("specularcolor",color)=(1,1,1,1)

        _OutLineColor("outlinecolor",color)=(0,0,0,0)
        _OutLineWidth("outlinewidth",range(0,0.01))=0.005
        _ZOutlineOffset("zoffset",range(-0.02,0.02))=0
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
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;//texcoord0
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldvertex:TEXCOORD1;//texcoord4
                float3 worldnormal:NORMAL;//texcoord1
                float3 worldtangent:TANGENT;//texcoord2
                float3 sidenormal:TEXCOORD2;//texcoord3
                float tangentw:TEXCOORD3;
                //float4 shadowcoord:TEXCOORD3;//texcoord6
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalTex;
            float4 _NormalTex_ST;
            sampler2D _PropertyTex;
            float4 _PropertyTex_ST;
            sampler2D _MaskTex;
            float4 _MaskTex_ST;
            sampler2D _ShadowRampTex;
            float4 _ShadowRampTex_ST;
            sampler2D _MatTex;
            float4 _MatTex_ST;
            sampler2D _MatRampTex;
            float4 _MatRampTex_ST;
            sampler2D _RefectionTex;
            float4 _RefectionTex_ST;
    


            float4 _MainColor;
            float4 _MatColor;
            float4 _ReflectColor;

            
            float _MatScale;
            float _ProbeScale;
            float _ReflectScale;

            float _RimLightThreshold;
            float _RimLightFade;
            float _RimLightRange;
            float3 _RimLightDir1;
            float3 _RimLightDir2;
            float4 _RimLightColor;
            float4 _EmissionColor;
            float4 _FillInner;
            float4 _FillOuter;
            float _FillClamp;


            float _ZOffset;
            float4 _ProbeLightBase;
            float _LightIndicesOffsetAndCount;
            float4 _unity_4LightIndices0;
            float4 _SimAddLightPos;
            float4 _SimAddLightColor;
            float4 _SimAddLightAttenuation;
            float _NormalScale;
            float4 _SimShadowLightDir;
            float _ShadowMaskScale;
            // float4 _ShadowOffset0;
            // float4 _ShadowOffset1;
            // float4 _ShadowOffset2;
            // float4 _ShadowOffset3;

            float _SpecularThreshold;
            float _SpecularFade;
            float4 _SpecularColor;            

            v2f vert (appdata v)
            {
                v2f o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldvertex=mul(unity_ObjectToWorld,v.vertex);
                float3 viewvertex=UnityObjectToViewPos(v.vertex);
                float3 preclip=viewvertex;
                preclip.z=preclip.z+_ZOffset;
                float2 clipfactor=UnityViewToClipPos(preclip).zw;
                //o.vertex=UnityWorldToClipPos(o.worldvertex);
                //o.vertex.z=clipfactor.x*o.vertex.w/clipfactor.y;
                o.worldnormal=normalize(UnityObjectToWorldNormal(v.normal));
                o.worldtangent=UnityObjectToWorldDir(v.tangent.xyz);
                o.sidenormal=cross(o.worldnormal,o.worldtangent)*v.tangent.w;
                o.tangentw=v.tangent.w;

                // float4 cascadeweights=GET_CASCADE_WEIGHTS(o.worldvertex,viewvertex.z);
                // o.shadowcoord=GET_SHADOW_COORDINATES(o.worldvertex,cascadeweights);
                // o.shadowcoord=TransformWorldToShadowCoord(o.worldvertex);
                // o.shadowcoord=mul(unity_WorldToShadow[0],float4(o.worldvertex.xyz,1));
                return o;
            }

            float mysmooth(float originnum)
            {
                float x = saturate(originnum);
                return x*x*(3-2*x);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 viewdir=normalize(_WorldSpaceCameraPos.xyz-i.worldvertex.xyz);
                //return float4(viewdir.xyz,1);
                float3 worldnormal=normalize(i.worldnormal);
                float3 worldtangent=normalize(i.worldtangent);
                float3 sidenormal=normalize(i.sidenormal);
                float4 maintex=tex2D(_MainTex,i.uv);
                //return float4((maintex.w==0).xxx,1);
                float4 maincolor=maintex*_MainColor;
                float3 pbrfactor=float3(0,0,0);
                //float4 shadowcoord=TransformWorldToShadowCoord(i.worldvertex);
                pbrfactor.x=_ProbeScale*unity_SHAr.w;
                pbrfactor.y=_ProbeScale*unity_SHAg.w;
                pbrfactor.z=_ProbeScale*unity_SHAb.w;
                //return pbrfactor.xyzz;
                pbrfactor=pbrfactor+_ProbeLightBase.xyz;
                //return pbrfactor.xyzz;
                // float lightindicesoffsetandcount=min(_LightIndicesOffsetAndCount,4);
                // float3 simlightdir=_SimAddLightPos-i.worldvertex;
                // float simlightdirdot=dot(simlightdir,simlightdir);
                // float attenuationone=1/(_SimAddLightAttenuation.x*simlightdirdot+1);
                // float attenuationtwo=saturate(_SimAddLightAttenuation.y*simlightdirdot+_SimAddLightAttenuation.z);
                // float3 simcolor=attenuationone*_SimAddLightColor.xyz*attenuationtwo;
                // float3 normalizedsimlightdir=normalize(simlightdir);
                // float3 simcolorfactor=saturate(dot(i.worldvertex.xyz,normalizedsimlightdir.xyz))*simcolor+pbrfactor;
                // float3 finalsimcolor=simcolorfactor*maincolor;
                //return maincolor;
                float4 pbr=maincolor*float4(pbrfactor.xyz,1);
                float3 normaltex=tex2D(_NormalTex,i.uv).xyz*2-float3(1,1,1);
                normaltex.xy=normaltex.xy*_NormalScale;
                float3 cusnormal=normalize(worldtangent.xyz*normaltex.x+sidenormal.xyz*normaltex.y+worldnormal.xyz*normaltex.z);
                //return cusnormal.xyzz;
                float thefresnel=dot(viewdir,cusnormal);
                float3 spevector = 2*cusnormal*thefresnel-viewdir;
                 spevector=mul((float3x3)UNITY_MATRIX_V,spevector)*0.5+float3(0,0,0.5);
                float3 viewspevector=normalize(spevector);
                float2 matuv=viewspevector.xy*0.5+float2(0.5,0.5);
                float3 mapmsg=float3(0,0,0);
                mapmsg.y=tex2Dlod(_PropertyTex,float4(i.uv,0,0)).w;//目测像是区分材质
                float4 masktex=tex2D(_MaskTex,i.uv);
                float cuslambert=max(dot(cusnormal,normalize(_WorldSpaceLightPos0)),0);
                mapmsg.x=min((1-min((1-masktex.w)*_ShadowMaskScale,1))*cuslambert,1);//目测像是计算光影漫反射的
                mapmsg.x=clamp(mapmsg.x,0.1,0.97);
                float4 ramptex=tex2D(_ShadowRampTex,mapmsg.xy);
                float4 rampcolor=ramptex*pbr;
                mapmsg.z=tex2D(_MatTex,matuv).x;
                //return  tex2D(_MatTex,matuv);
                float4 matramptex=tex2D(_MatRampTex,mapmsg.zy);
                float4 matrampcolor=matramptex*_MatColor;
                matrampcolor.xyz=lerp(float3(1,1,1),matrampcolor.xyz*_MatScale,masktex.x);
                matrampcolor=max(matrampcolor,float4(1,1,1,1))*rampcolor;

                float specularfac = thefresnel*masktex.y-_SpecularThreshold;
                specularfac=mysmooth(saturate(specularfac/_SpecularFade));
                float4 matcolor=specularfac*_SpecularColor+matrampcolor;
                //return matcolor;

                float rimfac=_RimLightThreshold+_RimLightFade;
                rimfac=spevector.z*(viewspevector/spevector)-rimfac;
                float rimfadefac=1/(-_RimLightFade);
                rimfac=saturate(rimfac*rimfadefac);
                rimfadefac=rimfac*(-2)+3;
                rimfac=rimfac*rimfac*rimfadefac;
                float rimdir1=dot(viewspevector,normalize(_RimLightDir1));
                float rimdir2=dot(viewspevector,normalize(_RimLightDir2));
                rimfadefac=saturate(max(rimdir1,rimdir2)+_RimLightRange);
                rimfac=min(rimfadefac,rimfac);
                float4 rimcolor=float4(rimfac*_RimLightColor.xyz,1);
                rimcolor.xyz=float3(1,1,1)-min(2*rimcolor.xyz*masktex.z,float3(0.99,0.99,0.99));
                rimcolor=matcolor/rimcolor;
                matcolor=min(max(matcolor,float4(2,2,2,2)),rimcolor);
                float4 emissioncolor=maincolor*_EmissionColor;
                float4 finalcolor = lerp(matcolor,emissioncolor,(maintex.w==0));
                finalcolor.w=(maintex.w==0)+(1-(maintex.w==0))*finalcolor.w;
                finalcolor.xyz=finalcolor*1.1;
                return finalcolor;
                float unknowfac=pow(1-pow(viewspevector.z,2),2);
                float4 fillcolor=lerp(_FillInner,_FillOuter,unknowfac);
                //return unknowfac;
                unknowfac=max(max(max(finalcolor.x,finalcolor.y),finalcolor.z),1);
                float4 fillfinalcolor=finalcolor/unknowfac;
                //return finalcolor;
                return fillfinalcolor;
                float4 realfinalcolor=(_FillClamp>0)*fillfinalcolor+(_FillClamp<=0)*finalcolor;
                //return realfinalcolor;
                realfinalcolor=lerp(realfinalcolor,fillcolor,fillcolor.w);
                return realfinalcolor;

                return float4(1,1,1,1);
            }
            ENDCG
        }
         Pass
        {
            cull front
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
                float4 vertex : SV_POSITION;
            };

            float4 _OutLineColor;
            float _OutLineWidth;
            float _ZOutlineOffset;
            sampler2D _PropertyTex;
            float4 _PropertyTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                float3 sidenormal=cross(v.normal,v.tangent.xyz);
                float3 normalcolor=2*v.color.xyz-float3(1,1,1);
                float3 cusnormal=normalize(v.tangent.xyz*normalcolor.x+sidenormal.xyz*normalcolor.y+v.normal.xyz*normalcolor.z);
                float3 clipcusnoraml=UnityObjectToClipPos(cusnormal);
                float2 normalxy=normalize(clipcusnoraml.xy)*v.color.w*_OutLineWidth;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float cusdepth=min(o.vertex.w,1);
                o.vertex.xy=o.vertex.xy+normalxy*cusdepth;
                float3 viewvertex=UnityObjectToViewPos(v.vertex);
                viewvertex.z=viewvertex.z+_ZOutlineOffset;
                float4 cusclipvertex=UnityViewToClipPos(viewvertex);
                o.vertex.z=o.vertex.w*cusclipvertex.z/cusclipvertex.w;
                o.uv = TRANSFORM_TEX(v.uv, _PropertyTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 propertytex=tex2D(_PropertyTex,i.uv);
               return float4(propertytex.xyz*_OutLineColor.xyz,1);
            }
            ENDCG
        }
    }
}
