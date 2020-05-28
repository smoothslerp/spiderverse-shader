Shader "Unlit/spiderverse_unlit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "grey" {}
        _LightenScale("_LightenScale", Range(0,1)) = 0.5
        _DarkenScale("_DarkenScale", Range(0,1)) = 0.5
        _cScale("cScale", Range(1,500)) = 1
        _lScale("lScale", Range(1,500)) = 1
        _Rotation("Rotation", Range(0,360)) = 0
        _MinRadius("_MinRadius", Range(0,1)) = .1 // if lower than this, no circle is shown
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM

            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                half3 normal: NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                half3 normal: NORMAL;
                float4 screenPos: TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _cScale;
            float _lScale;
            float _Rotation;
            float _LightenScale;
            float _DarkenScale;

            float _MinRadius;

            float circle(float2 st, float radius) {
                float d = distance(st,float2(0.5, 0.5)) * sqrt(2);
                return step(d,radius);
            }

            float2 rotate(float2 p, float theta) {
                return float2(p.x * cos(theta) - p.y * sin(theta),
                              p.x * sin(theta) + p.y * cos(theta));
            }

            v2f vert (appdata v) {
                
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                float4 aspectv = o.vertex;
                aspectv.x *= _ScreenParams.x / _ScreenParams.y;   
                o.screenPos = ComputeScreenPos(aspectv);
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = v.normal;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target {   
                
                float4 tex = tex2D(_MainTex, i.uv);
                float NdotL = dot(i.normal, -_WorldSpaceLightPos0.xyz);
                
                // perspective divide & rotation 
                float2 st = rotate(i.screenPos.xy/i.screenPos.w, _Rotation * 3.14159/180);
                float2 cst = frac(st*_cScale);
                float2 lst = frac(st*_lScale);

                // circle pattern
                float circles = circle(cst, step(_MinRadius, NdotL) * NdotL);
                // line pattern NdotL*-1 to draw these where the sun dont shine. 
                float lines = step(lst.x, -NdotL); 
                
                fixed4 tDark = (1-_DarkenScale) * tex;
                fixed4 tBright = 1 - ((1-_LightenScale) * (1 - tex)); 
                
                // blend with tex*_Color
                float eff = circles + lines;
                fixed4 col = circles * tBright + lines * tDark + (1-eff) * tex;

                return col;
            }
            
            ENDCG
        }
    }
}
