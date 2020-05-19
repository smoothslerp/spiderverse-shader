Shader "Custom/spiderverse"
{
    Properties
    {
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

        float fadeCircle(float2 st, float radius, float fadeWidth) {
            // inner-circle radius
            float ic = radius - fadeWidth;
            float d = distance(st,float2(0.5, 0.5));
            float fc = 1.-invLerp(ic, radius, d);
            
            return fc;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            
            o.Albedo = c.rgb;
            o.Alpha = c.a;
            
        }

        half4 LightingCustomLighting (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {
            half NdotL = dot(s.Normal, lightDir);
            half stepDotL = floor(NdotL*10)/10; // this forms a staircase... we want it to be a bubbly staircase

            // get the dot product of surface normal and view direction
            half NDotV = dot(s.Normal, viewDir); 

            half4 c;
            
            c.rgb = s.Albedo * _LightColor0.rgb * (stepDotL * atten);
            c.a = s.Alpha;
            return c;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
