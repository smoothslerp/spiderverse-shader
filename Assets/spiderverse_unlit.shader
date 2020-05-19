Shader "Unlit/spiderverse_unlit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _ColorDark ("ColorDark", Color) = (0,0,0,1)
        _ColorBright ("ColorBright", Color) = (1,1,1,1)
        _Rotation("Rotation", Range(0,360)) = 0
        _Scale("Scale", Range(1,500)) = 1
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

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                half3 normal: NORMAL;
                // half3 tangent: TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 screenPos: TEXCOORD1;
                float4 vertex : SV_POSITION;
                half3 normal: NORMAL;
                // half3 tangent: TANGENT;
                float3 lightDir: POSITION1;
                // half3 viewDir: POSITION2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Rotation;
            float _Scale;

            float4 _Color;
            float4 _ColorDark;
            float4 _ColorBright;

            float circle(float2 st, float radius) {
                float d = distance(st,float2(0.5, 0.5)) * sqrt(2);
                return step(d,radius);
            }

            float2 rotate(float2 p, float theta) {
                return float2(p.x * cos(theta)  - p.y * sin(theta),
                              p.x * sin(theta) + p.y * cos(theta));
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = v.normal;
                // o.tangent = v.tangent;
                // o.viewDir = ObjSpaceViewDir(v.vertex);
                o.lightDir = _WorldSpaceLightPos0.xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {   
                
                float4 tex = tex2D(_MainTex, i.uv);
                float NdotL = dot(i.normal, i.lightDir);
                
                // divide by screenPos.w for perspective divide, divide by camPos.z to scale with camera distance
                float2 st = rotate((i.screenPos.xy/(_WorldSpaceCameraPos.z * i.screenPos.w)), _Rotation * 3.14159/180);
                st = frac(st*_Scale);

                // circle pattern
                float c = circle(st, NdotL);
                // line pattern dot(i.normal, -i.lightDir)=NdotL*-1 to draw these where the sun dont shine. 
                float l = step(st.x, -NdotL); 
                // adds up to at most 1
                float eff = c + l;

                // blend effects color
                fixed4 effCol = c * _ColorBright + l * _ColorDark;
                // blend with tex*_Color
                fixed4 col = eff * effCol + (1-eff) * tex * _Color;
                // return fixed4(st.xy, 0,0);
                return col;
            }

            
            ENDCG
        }
    }
}
