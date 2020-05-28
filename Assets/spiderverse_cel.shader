Shader "Custom/spiderverse_cel"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("Bumpmap", 2D) = "bump" {}
        _AmbientColor ("Ambient Color", Color) = (0,0,0,1)
        _AmbientStrength("_AmbientStrength", Range(0,1)) = 0.5
        _LightenScale("_LightenScale", Range(0,1)) = 0.5
        _DarkenScale("_DarkenScale", Range(0,1)) = 0.5
        _Rotation("Rotation", Range(0,360)) = 0
        _cScale("cScale", Range(1,100)) = 1
        _lScale("lScale", Range(1,100)) = 1

        _Step("Step", Range(0,20)) = 4
        _ClampA("_ClampA", Range(0,1)) = .2
        _ClampB("_ClampB", Range(0,1)) = .8

        _MinRadius("_MinRadius", Range(0,1)) = .1 // if lower than this, no circle is shown

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM

        #include "UnityCG.cginc"
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Custom

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0


        sampler2D _MainTex;
        sampler2D _BumpMap;
        float _Rotation;
        float _cScale;
        float _lScale;
        float _LightenScale;
        float _DarkenScale;

        float4 _AmbientColor;
        float _AmbientStrength;

        int _Step;
        float _ClampA;
        float _ClampB;

        float _MinRadius;

        struct Input
        {
            float2 uv_MainTex;
            float3 vertex;
            float3 viewDir;
            float3 vertexNormal; // This will hold the vertex normal
            float4 screenPos;
            float2 uv_BumpMap;
        };

        struct SurfaceOutputCustom {
            fixed3 Albedo;
            fixed3 Normal;
            fixed3 Emission;
            fixed Alpha;
            float2 textureCoordinate;
        };

        float circle(float2 st, float radius) {
            float d = distance(st,float2(0.5, 0.5)) * sqrt(2);
            return step(d,radius);
        }

        float2 rotate(float2 p, float theta) {
            return float2(p.x * cos(theta) - p.y * sin(theta),
                            p.x * sin(theta) + p.y * cos(theta));
        }

        void surf (Input IN, inout SurfaceOutputCustom o) {
            float4 tex = tex2D(_MainTex, IN.uv_MainTex);

            float2 textureCoordinate = IN.screenPos.xy / IN.screenPos.w; // perspective divide
            float aspect = _ScreenParams.x / _ScreenParams.y;
            textureCoordinate.x = textureCoordinate.x * aspect;

            o.Albedo = tex.rgb;
            o.textureCoordinate = textureCoordinate;
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            o.Alpha = 1;
        }

        half4 LightingCustom (SurfaceOutputCustom s, half3 lightDir, half3 viewDir) {
            float2 st = rotate(s.textureCoordinate, _Rotation * 3.14/180);

            float2 cst = frac(st*_cScale);
            float2 lst = frac(st*_lScale);
            
            float NdotL = dot(s.Normal, lightDir);
            // circle pattern
            float circles = circle(cst, step(_MinRadius, NdotL) * NdotL);
            // line pattern NdotL*-1 to draw these where the sun dont shine. 
            float lines = step(lst.x, -NdotL);

            half cel = clamp(floor(max(NdotL, 0) * _Step)/_Step, _ClampA, _ClampB);

            half4 col;
            half3 l = (s.Albedo * _LightColor0.rgb * cel + _AmbientColor * _AmbientStrength);
            half3 lDark = (1-_DarkenScale) * l;
            half3 lBright = 1 - ((1-_LightenScale) * (1 - l)); 

            col.rgb = (1-(circles+lines)) * l + circles * lBright + lines * lDark;
            col.a = s.Alpha;
            
            return col;
        }

        ENDCG
    }
    FallBack "Diffuse"
}