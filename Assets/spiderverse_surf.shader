Shader "Custom/spiderverse"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AmbientColor ("Ambient Color", Color) = (0,0,0,1)
        _AmbientStrength("_AmbientStrength", Range(0,1)) = 0.5
        _LightenScale("_LightenScale", Range(0,1)) = 0.5
        _DarkenScale("_DarkenScale", Range(0,1)) = 0.5
        _SpecularK("Specular Constant", Int) = 32
        _Rotation("Rotation", Range(0,360)) = 0
        _cScale("cScale", Range(1,100)) = 1
        _lScale("lScale", Range(1,100)) = 1
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
        // float4 _MainTex_ST;
        float _Rotation;
        float _cScale;
        float _lScale;
        float _LightenScale;
        float _DarkenScale;

        float4 _AmbientColor;
        float _AmbientStrength;
        int _SpecularK;

        struct Input
        {
            float2 uv_MainTex;
            float3 vertex;
            float3 viewDir;
            float3 vertexNormal; // This will hold the vertex normal
            float4 screenPos;
        };

        struct SurfaceOutputCustom {
            fixed3 Albedo;
            fixed3 Normal;
            fixed3 Emission;
            half Specular;
            fixed Gloss;
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

            // divide by screenPos.w for perspective divide
            float2 textureCoordinate = IN.screenPos.xy / IN.screenPos.w;
            float aspect = _ScreenParams.x / _ScreenParams.y;
            textureCoordinate.x = textureCoordinate.x * aspect;

            o.Albedo = tex.rgb;
            o.textureCoordinate = textureCoordinate;
            o.Normal = IN.vertexNormal;
            o.Alpha = 1;
        }

        half4 LightingCustom (SurfaceOutputCustom s, half3 lightDir, half3 viewDir) {
            float NdotL = dot(s.Normal, lightDir);
            float2 st = rotate(s.textureCoordinate, _Rotation * 3.14159/180);
            float2 cst = frac(st*_cScale);
            float2 lst = frac(st*_lScale);

            // circle pattern
            float c = circle(cst, NdotL);
            // line pattern NdotL*-1 to draw these where the sun dont shine. 
            float l = step(lst.x, -NdotL); 

            float eff = c + l; 

            half3 h = normalize (lightDir + viewDir);
            half diff = max (0, NdotL);
            float nh = max (0, dot (s.Normal, reflect(-lightDir, s.Normal)));
            float spec = pow (nh, _SpecularK);

            half4 col;
            float3 lighting = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec + _AmbientColor * _AmbientStrength);

            half3 lightingDark = (1-_DarkenScale) * lighting; // .5 is the scale factor
            half3 lightingBright = 1 - ((1-_LightenScale) * (1 - lighting)); // .5 is the scale factor


            col.rgb = (1-eff) * lighting + c * lightingBright + l * lightingDark;
            // col.rgb = lighting;
            col.a = s.Alpha;
            
            return col;
        }

        ENDCG
    }
    FallBack "Diffuse"
}