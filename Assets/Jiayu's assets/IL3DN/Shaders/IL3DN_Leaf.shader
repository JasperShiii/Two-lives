// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "IL3DN/Leaf"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_AlphaCutoff("Alpha Cutoff", Range( 0 , 1)) = 0.5
		_MainTex("MainTex", 2D) = "white" {}
		[Toggle(_SNOW_ON)] _Snow("Snow", Float) = 1
		[Toggle(_WIND_ON)] _Wind("Wind", Float) = 1
		_WindStrenght("Wind Strenght", Range( 0 , 1)) = 0.5
		[Toggle(_WIGGLE_ON)] _Wiggle("Wiggle", Float) = 1
		_WiggleStrenght("Wiggle Strenght", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" }
		Cull Off
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#pragma multi_compile __ _WIND_ON
		#pragma multi_compile __ _SNOW_ON
		#pragma multi_compile __ _WIGGLE_ON
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			float2 uv_texcoord;
		};

		uniform float3 WindDirection;
		uniform float _WindStrenght;
		uniform float WindSpeedFloat;
		uniform float WindTurbulenceFloat;
		uniform float WindStrenghtFloat;
		uniform float SnowLeavesFloat;
		uniform float4 _Color;
		uniform sampler2D _MainTex;
		uniform float LeavesWiggleFloat;
		uniform float _WiggleStrenght;
		uniform float AlphaCutoffFloat;
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
			float worldNoise905 = simplePerlin2D712;
			float4 transform886 = mul(unity_WorldToObject,float4( ( WindDirection * ( simplePerlin2D879 * ( _WindStrenght * ( ( v.color.a * worldNoise905 ) + ( worldNoise905 * v.color.g ) ) * WindStrenghtFloat ) ) ) , 0.0 ));
			#ifdef _WIND_ON
				float4 staticSwitch897 = transform886;
			#else
				float4 staticSwitch897 = float4( 0,0,0,0 );
			#endif
			v.vertex.xyz += staticSwitch897.xyz;
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldNormal = i.worldNormal;
			#ifdef _SNOW_ON
				float staticSwitch917 = ( saturate( pow( ase_worldNormal.y , 1.0 ) ) * SnowLeavesFloat );
			#else
				float staticSwitch917 = 0.0;
			#endif
			float3 worldToObjDir883 = mul( unity_WorldToObject, float4( (WindDirection).xzy, 0 ) ).xyz;
			float3 ase_worldPos = i.worldPos;
			float2 panner706 = ( 1.0 * _Time.y * ( worldToObjDir883 * WindSpeedFloat ).xy + (ase_worldPos).xz);
			float simplePerlin2D712 = snoise( ( ( panner706 * 0.25 ) * WindTurbulenceFloat ) );
			float worldNoise905 = simplePerlin2D712;
			float2 temp_cast_1 = (( worldNoise905 * 2.5 )).xx;
			float simplePerlin2D797 = snoise( temp_cast_1 );
			float cos745 = cos( ( simplePerlin2D797 * LeavesWiggleFloat * _WiggleStrenght ) );
			float sin745 = sin( ( simplePerlin2D797 * LeavesWiggleFloat * _WiggleStrenght ) );
			float2 rotator745 = mul( i.uv_texcoord - float2( 0.25,0.25 ) , float2x2( cos745 , -sin745 , sin745 , cos745 )) + float2( 0.25,0.25 );
			#ifdef _WIGGLE_ON
				float2 staticSwitch898 = rotator745;
			#else
				float2 staticSwitch898 = i.uv_texcoord;
			#endif
			float4 tex2DNode97 = tex2D( _MainTex, staticSwitch898 );
			o.Albedo = saturate( ( staticSwitch917 + ( _Color * tex2DNode97 ) ) ).rgb;
			o.Alpha = 1;
			#ifdef _SNOW_ON
				float staticSwitch921 = AlphaCutoffFloat;
			#else
				float staticSwitch921 = 1.0;
			#endif
			clip( ( tex2DNode97.a / staticSwitch921 ) - _AlphaCutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma exclude_renderers vulkan xbox360 psp2 n3ds wiiu 
		#pragma surface surf Lambert keepalpha fullforwardshadows nolightmap  nodirlightmap dithercrossfade vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=17009
395;299;1636;1162;-1335.565;61.77778;2.009323;True;True
Node;AmplifyShaderEditor.Vector3Node;867;817.415,1344.312;Float;False;Global;WindDirection;WindDirection;14;0;Create;True;0;0;False;0;0,0,0;-0.7071068,0,-0.7071068;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;909;1197.83,1453.756;Inherit;False;1616.924;573.676;World Noise;11;712;750;751;749;706;884;873;714;708;883;882;World Noise;1,0,0.02020931,1;0;0
Node;AmplifyShaderEditor.SwizzleNode;882;1296.722,1729.092;Inherit;False;FLOAT3;0;2;1;2;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformDirectionNode;883;1504.722,1729.092;Inherit;False;World;Object;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;714;1461.028,1905.042;Float;False;Global;WindSpeedFloat;WindSpeedFloat;3;0;Create;True;0;0;False;0;10;2;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;708;1501.092,1526.954;Float;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;873;1842.531,1522.594;Inherit;False;FLOAT2;0;2;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;884;1826.611,1874.677;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PannerNode;706;2050.301,1525.508;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleNode;749;2261.701,1523.591;Inherit;False;0.25;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;750;2088.474,1711.146;Float;False;Global;WindTurbulenceFloat;WindTurbulenceFloat;4;0;Create;True;0;0;False;0;0.25;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;751;2437.135,1523.685;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;712;2615.417,1518.595;Inherit;True;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;905;2861.922,1520.478;Float;False;worldNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;907;1540.259,843.3633;Inherit;False;905;worldNoise;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;899;1792.495,773.7919;Inherit;False;1012.714;535.89;UV Animation;7;795;799;746;745;797;904;798;UV Animation;0.7678117,1,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;908;1983.116,2406.605;Inherit;False;830.5812;671.3536;Vertex Animation;8;754;755;857;888;855;854;856;853;Vertex Animation;0,1,0.8708036,1;0;0
Node;AmplifyShaderEditor.ScaleNode;795;1836.776,845.15;Inherit;False;2.5;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;853;2036.065,2481.375;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;906;1729.908,2713.099;Inherit;False;905;worldNoise;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;856;2040.763,2894.441;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;797;2002.644,842.9209;Inherit;True;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;904;1934.416,1210.809;Float;False;Property;_WiggleStrenght;Wiggle Strenght;8;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;911;1727.516,274.4578;Inherit;False;1075.409;358.2535;Snow;5;916;915;914;913;912;Snow;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;798;1934.886,1116.013;Float;False;Global;LeavesWiggleFloat;LeavesWiggleFloat;5;0;Create;True;0;0;False;0;0.26;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;912;1763.288,348.2159;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;746;2276.372,835.3718;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;799;2365.897,1117.559;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;855;2309.503,2778.177;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;876;2420.847,2070.403;Inherit;False;390.5991;274.1141;Strenght Noise;2;879;877;;1,0.6156863,0,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;854;2306.502,2640.616;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;888;2316.906,2908.086;Float;False;Global;WindStrenghtFloat;WindStrenghtFloat;3;0;Create;True;0;0;False;0;0.5;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;857;2457.943,2701.816;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;755;2310.631,2541.86;Float;False;Property;_WindStrenght;Wind Strenght;6;0;Create;True;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;877;2436.847,2119.71;Inherit;False;1;0;FLOAT;0.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;745;2544.405,976.8619;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0.25,0.25;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;913;2039.218,394.2268;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;879;2609.243,2119.71;Inherit;True;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;754;2639.659,2678.943;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;914;2225.051,394.0062;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;915;1750.874,543.1254;Inherit;False;Global;SnowLeavesFloat;SnowLeavesFloat;4;0;Create;True;0;0;False;0;1;1;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;898;3693.987,1190.03;Float;False;Property;_Wiggle;Wiggle;7;0;Create;True;0;0;False;0;1;1;0;True;_WIND_ON;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;97;3955.139,1167.211;Inherit;True;Property;_MainTex;MainTex;2;0;Create;True;0;0;False;0;None;6ab0f5f5ed2482e43a5ace7eeced19e6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;292;4011.016,958.6533;Float;False;Property;_Color;Color;0;0;Create;True;0;0;False;0;1,1,1,1;0.7058823,0.5882353,0.1843136,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;916;2451.704,524.162;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;881;2916.681,2127.176;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;920;3644.657,1669.175;Inherit;False;Global;AlphaCutoffFloat;AlphaCutoffFloat;2;0;Create;False;0;0;False;0;2.1;2.1;1;2.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;872;3207.503,1341.415;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;293;4285.25,1058.456;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;917;3684.1,518.5128;Inherit;False;Property;_Snow;Snow;4;0;Create;True;0;0;False;0;1;1;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;919;3770.889,1559.604;Inherit;False;Constant;_Float1;Float 0;9;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;886;3401.475,1340.256;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;921;4156.484,1631.802;Inherit;False;Property;_Snow2;Snow;3;0;Create;True;0;0;False;0;1;1;0;True;_SNOW_ON;Toggle;2;Key0;Key1;Reference;917;False;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;918;4383.962,637.7845;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;897;3701.915,1311.666;Float;False;Property;_Wind;Wind;5;0;Create;True;0;0;False;0;1;1;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;922;4329.29,1262.201;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;910;3971.231,1403.038;Float;False;Property;_AlphaCutoff;Alpha Cutoff;1;0;Create;True;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;923;4546.297,1048.91;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;4713.688,1052.534;Float;False;True;2;;0;0;Lambert;IL3DN/Leaf;False;False;False;False;False;False;True;False;True;False;False;False;True;False;False;False;True;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.5;True;True;0;False;TransparentCutout;;AlphaTest;All;9;d3d9;d3d11_9x;d3d11;glcore;gles;gles3;metal;xboxone;ps4;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;1;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;892;-1;0;True;910;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
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
WireConnection;905;0;712;0
WireConnection;795;0;907;0
WireConnection;797;0;795;0
WireConnection;799;0;797;0
WireConnection;799;1;798;0
WireConnection;799;2;904;0
WireConnection;855;0;906;0
WireConnection;855;1;856;2
WireConnection;854;0;853;4
WireConnection;854;1;906;0
WireConnection;857;0;854;0
WireConnection;857;1;855;0
WireConnection;745;0;746;0
WireConnection;745;2;799;0
WireConnection;913;0;912;2
WireConnection;879;0;877;0
WireConnection;754;0;755;0
WireConnection;754;1;857;0
WireConnection;754;2;888;0
WireConnection;914;0;913;0
WireConnection;898;1;746;0
WireConnection;898;0;745;0
WireConnection;97;1;898;0
WireConnection;916;0;914;0
WireConnection;916;1;915;0
WireConnection;881;0;879;0
WireConnection;881;1;754;0
WireConnection;872;0;867;0
WireConnection;872;1;881;0
WireConnection;293;0;292;0
WireConnection;293;1;97;0
WireConnection;917;0;916;0
WireConnection;886;0;872;0
WireConnection;921;1;919;0
WireConnection;921;0;920;0
WireConnection;918;0;917;0
WireConnection;918;1;293;0
WireConnection;897;0;886;0
WireConnection;922;0;97;4
WireConnection;922;1;921;0
WireConnection;923;0;918;0
WireConnection;0;0;923;0
WireConnection;0;10;922;0
WireConnection;0;11;897;0
ASEEND*/
//CHKSM=E48E8569BCF8BBD247E0EE6408CBAFA0199FAAD2