Shader "Hidden/RenderFilter/Palette"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Palette ("Palette", 2D) = "red" {}
        _NoiseVal ("Noise Factor", Float) = 0.4
        _ScreenRes ("Screen Resolution (only x,y is used)", Vector) = (480, 270, 0,0)
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            sampler2D _Palette;
            float _NoiseVal; 
            float4 _ScreenRes;

            fixed4 frag (v2f i) : SV_Target
            {
                // Constants 
                // TODO: Move to RenderCombine script
                matrix <float, 4, 4> fMatrix = // Bayer matrix
                { 
                    0,8,2,10,
                    12,4,14,6,
                    3,11,1,9,
                    15,7,13,5
                };

                // Samples
                float4 col = tex2D(_MainTex, i.uv);
                
                // Salting
                col.rgb *= (15*(1-_NoiseVal) + _NoiseVal * fMatrix[i.uv.x * _ScreenRes.x % 4][i.uv.y * _ScreenRes.y % 4]);
                col.rgb *= 0.066666666;

                // Apply filters
                float x; 
                float cDist;
                float4 pColor;
                float4 colf = col;
                float2 coordinate = {0,0.5};
                float mDist = 1000000000;
                for (x=1; x <= 8; x++ ) 
                {
                    // 1->8 * 0.1111111111111
                    // TODO: FIX PRECISION
                    coordinate.x = x*0.11111111;
                    pColor = tex2D(_Palette, coordinate);
                    cDist = distance(pColor, col);
                    if(cDist < mDist) { colf = pColor; mDist = cDist; }
                } 

                // Set correct alpha
                colf.a = col.a;

                // Return paletted pixel
		        return colf;
            }
            ENDCG
        }
    }
}
