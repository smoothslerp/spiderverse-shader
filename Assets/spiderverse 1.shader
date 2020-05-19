Shader "Custom/spiderverse1"
{
    Properties
    {
        _N("N", Range(0,20)) = 5
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        
        #include "UnityCG.cginc"
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0


        sampler2D _MainTex;
        float4 _Color;
        float _N;

        struct Input
        {
            float2 uv_MainTex;
            // float2 uv_BumpMap;
            float3 vertex;
            float3 viewDir;
            float3 vertexNormal; // This will hold the vertex normal
        };

        float invLerp(float a, float b, float v) {
            return (v - a)/(b - a);
        }

        float fadeCircle(float2 st, float radius) {
            // inner-circle radius
            float d = distance(st,float2(0.5, 0.5));
            return step(d,radius);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            
            // fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            float2 st1 = IN.uv_MainTex.xy;
            float f = floor(st1.y*_N)/_N;
            float fMinus1 = f - 1/_N;
            
            float2 st2 = frac(IN.uv_MainTex.xy*_N);
            float fc = fadeCircle(st2 + float2(0,0.5), 0.1) * fMinus1; // +.5 to move them down

            o.Albedo = float3(fc+f,fc+f,fc+f);
            // o.Albedo = float3(fc,fc,fc);
            o.Alpha = 1;
            
        }

        ENDCG
    }
    FallBack "Diffuse"
}

