// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "IL3DN/CardComplex"
{
	Properties
	{
		_Bark("Bark", Color) = (0,0,0,0)
		_Leaves("Leaves", Color) = (1,1,1,1)
		_AlphaCutoff("Alpha Cutoff", Range( 0 , 1)) = 0.5
		_MainTex("MainTex", 2D) = "white" {}
		[Toggle(_WIND_ON)] _Wind("Wind", Float) = 1
		_WindStrenght("Wind Strenght", Range( 0 , 1)) = 0.5
		[Toggle(_ISDEAD_ON)] _IsDead("Is Dead", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Off
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma multi_compile __ _WIND_ON
		#pragma shader_feature _ISDEAD_ON
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows dithercrossfade vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform float3 WindDirection;
		uniform float _WindStrenght;
		uniform float WindSpeedFloat;
		uniform float WindTurbulenceFloat;
		uniform float WindStrenghtFloat;
		uniform float4 _Bark;
		uniform float4 _Leaves;
		uniform sampler2D _MainTex;
		uniform float _AlphaCutoff;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float mulTime877 = _Time.y * 0.25;
			float2 temp_cast_0 = (mulTime877).xx;
			float simplePerlin2D879 = snoise( temp_cast_0 );
			float3 worldToObjDir883 = mul( unity_WorldToObject, float4( (WindDirection).xzy, 0 ) ).xyz;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float2 panner706 = ( 1.0 * _Time.y * ( worldToObjDir883 * WindSpeedFloat ).xy + (ase_worldPos).xz);
			float simplePerlin2D712 = snoise( ( ( panner706 * 0.25 ) * WindTurbulenceFloat ) );
			float worldNoise908 = simplePerlin2D712;
			float4 transform886 = mul(unity_WorldToObject,float4( ( WindDirection * ( simplePerlin2D879 * ( _WindStrenght * ( ( v.color.a * worldNoise908 ) + ( worldNoise908 * v.color.g ) ) * WindStrenghtFloat ) ) ) , 0.0 ));
			#ifdef _WIND_ON
				float4 staticSwitch897 = transform886;
			#else
				float4 staticSwitch897 = float4( 0,0,0,0 );
			#endif
			v.vertex.xyz += staticSwitch897.xyz;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_TexCoord905 = i.uv_texcoord + float2( 0,-0.5 );
			#ifdef _ISDEAD_ON
				float2 staticSwitch903 = uv_TexCoord905;
			#else
				float2 staticSwitch903 = i.uv_texcoord;
			#endif
			float4 tex2DNode97 = tex2D( _MainTex, staticSwitch903 );
			float4 lerpResult901 = lerp( _Bark , _Leaves , tex2DNode97.g);
			o.Emission = lerpResult901.rgb;
			o.Alpha = 1;
			clip( tex2DNode97.a - _AlphaCutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17009
1412;229;1636;1168;-3470.387;-360.2299;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;911;1575.209,775.076;Inherit;False;1752.393;564.8602;World Noise;12;908;712;751;750;749;706;884;873;708;714;883;882;;1,0,0.02020931,1;0;0
Node;AmplifyShaderEditor.Vector3Node;867;1274.78,1334.219;Float;False;Global;WindDirection;WindDirection;14;0;Create;True;0;0;False;0;0,0,0;-0.7071068,0,-0.7071068;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;882;1614.105,1048.482;Inherit;False;FLOAT3;0;2;1;2;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;714;1771.266,1236.89;Float;False;Global;WindSpeedFloat;WindSpeedFloat;3;0;Create;True;0;0;False;0;10;5;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;883;1822.105,1048.482;Inherit;False;World;Object;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;708;1816.683,835.0251;Float;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;873;2093.213,831.076;Inherit;False;FLOAT2;0;2;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;884;2091.085,1136.998;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PannerNode;706;2298.215,837.5019;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;750;2354.941,1000.518;Float;False;Global;WindTurbulenceFloat;WindTurbulenceFloat;4;0;Create;True;0;0;False;0;0.25;0.25;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;749;2491.038,841.7689;Inherit;False;0.25;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;751;2674.218,839.9846;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;712;2848.927,836.2619;Inherit;True;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;910;2589.704,1798.64;Inherit;False;732.2339;650.6468;Vertex Animation;9;754;888;857;755;854;855;853;856;909;;0,1,0.8708036,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;908;3097.538,842.0944;Float;False;worldNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;909;2609.843,2083.599;Inherit;False;908;worldNoise;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;856;2631.469,2254.376;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;853;2629.741,1846.2;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;876;2937.935,1456.006;Inherit;False;390.5991;274.1141;Strenght Noise;2;879;877;;1,0.6156863,0,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;855;2845.202,2167.159;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;854;2842.202,1974.159;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;888;2840.266,2277.372;Float;False;Global;WindStrenghtFloat;WindStrenghtFloat;3;0;Create;True;0;0;False;0;0.5;0.25;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;877;2953.935,1505.315;Inherit;False;1;0;FLOAT;0.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;755;2833.383,1886.595;Float;False;Property;_WindStrenght;Wind Strenght;5;0;Create;True;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;857;3006.01,2059.615;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;754;3162.322,2036.821;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;912;3356.258,775.67;Inherit;False;264.2837;355.7888;Offset UV;2;905;906;;0,1,0.8708036,1;0;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;879;3126.331,1505.315;Inherit;True;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;881;3393.556,1506.596;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;906;3382.084,833.7921;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;905;3379.926,985.2769;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,-0.5;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;872;3568.628,1342.612;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;903;3668.91,908.465;Float;False;Property;_IsDead;Is Dead;6;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;902;3978.698,532.9936;Float;False;Property;_Bark;Bark;0;0;Create;True;0;0;False;0;0,0,0,0;0.5377356,0.3495415,0.1953092,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;97;3883.688,1098.528;Inherit;True;Property;_MainTex;MainTex;3;0;Create;True;0;0;False;0;None;46fa255f11489784a86ff91e1485cca5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;292;3975.695,723.3113;Float;False;Property;_Leaves;Leaves;1;0;Create;True;0;0;False;0;1,1,1,1;0.06274467,0.3686269,0.2644943,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldToObjectTransfNode;886;3753.615,1344.448;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;901;4376.639,631.6848;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;897;3983.99,1315.858;Float;False;Property;_Wind;Wind;4;0;Create;True;0;0;False;0;1;1;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;907;4268.722,506.8607;Float;False;Property;_AlphaCutoff;Alpha Cutoff;2;0;Create;True;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;900;4851.913,1065.111;Float;False;True;2;ASEMaterialInspector;0;0;Unlit;IL3DN/CardComplex;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.5;True;True;0;False;TransparentCutout;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;True;907;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;882;0;867;0
WireConnection;883;0;882;0
WireConnection;873;0;708;0
WireConnection;884;0;883;0
WireConnection;884;1;714;0
WireConnection;706;0;873;0
WireConnection;706;2;884;0
WireConnection;749;0;706;0
WireConnection;751;0;749;0
WireConnection;751;1;750;0
WireConnection;712;0;751;0
WireConnection;908;0;712;0
WireConnection;855;0;909;0
WireConnection;855;1;856;2
WireConnection;854;0;853;4
WireConnection;854;1;909;0
WireConnection;857;0;854;0
WireConnection;857;1;855;0
WireConnection;754;0;755;0
WireConnection;754;1;857;0
WireConnection;754;2;888;0
WireConnection;879;0;877;0
WireConnection;881;0;879;0
WireConnection;881;1;754;0
WireConnection;872;0;867;0
WireConnection;872;1;881;0
WireConnection;903;1;906;0
WireConnection;903;0;905;0
WireConnection;97;1;903;0
WireConnection;886;0;872;0
WireConnection;901;0;902;0
WireConnection;901;1;292;0
WireConnection;901;2;97;2
WireConnection;897;0;886;0
WireConnection;900;2;901;0
WireConnection;900;10;97;4
WireConnection;900;11;897;0
ASEEND*/
//CHKSM=934FE9949A29BECBD9A2292355F0302F812FEBEC