// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "IL3DN/Branch"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("MainTex", 2D) = "white" {}
		[Toggle(_SNOW_ON)] _Snow("Snow", Float) = 1
		[Toggle(_WIND_ON)] _Wind("Wind", Float) = 1
		_WindStrenght("Wind Strenght", Range( 0 , 1)) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#pragma shader_feature _WIND_ON
		#pragma multi_compile __ _SNOW_ON
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			float2 uv_texcoord;
		};

		uniform float _WindStrenght;
		uniform float3 WindDirection;
		uniform float WindSpeedFloat;
		uniform float WindTurbulenceFloat;
		uniform float WindStrenghtFloat;
		uniform float SnowBranchesFloat;
		uniform float4 _Color;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;


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
			float mulTime906 = _Time.y * 0.25;
			float2 temp_cast_0 = (mulTime906).xx;
			float simplePerlin2D908 = snoise( temp_cast_0 );
			float3 worldToObjDir904 = mul( unity_WorldToObject, float4( (WindDirection).xzy, 0 ) ).xyz;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float2 panner706 = ( 1.0 * _Time.y * ( worldToObjDir904 * WindSpeedFloat ).xy + (ase_worldPos).xz);
			float simplePerlin2D712 = snoise( ( ( panner706 * 0.25 ) * WindTurbulenceFloat ) );
			float worldNoise917 = simplePerlin2D712;
			float4 transform913 = mul(unity_WorldToObject,float4( ( ( simplePerlin2D908 * ( _WindStrenght * ( ( v.color.a * worldNoise917 ) + ( worldNoise917 * v.color.g ) ) * WindStrenghtFloat ) ) * WindDirection ) , 0.0 ));
			#ifdef _WIND_ON
				float4 staticSwitch915 = transform913;
			#else
				float4 staticSwitch915 = float4( 0,0,0,0 );
			#endif
			v.vertex.xyz += staticSwitch915.xyz;
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldNormal = i.worldNormal;
			#ifdef _SNOW_ON
				float staticSwitch926 = ( saturate( pow( ase_worldNormal.y , 1.0 ) ) * SnowBranchesFloat );
			#else
				float staticSwitch926 = 0.0;
			#endif
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			o.Albedo = saturate( ( staticSwitch926 + ( _Color * tex2D( _MainTex, uv_MainTex ) ) ) ).rgb;
			o.Alpha = 1;
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
395;299;1636;1162;-634.1639;307.4576;2.348073;True;True
Node;AmplifyShaderEditor.CommentaryNode;919;1520.42,778.2395;Inherit;False;1535.807;564.3376;World Noise;11;712;859;860;858;706;912;911;714;708;904;903;World Noise;1,0,0.02020931,1;0;0
Node;AmplifyShaderEditor.Vector3Node;902;1189.348,1350.45;Float;False;Global;WindDirection;WindDirection;14;0;Create;True;0;0;False;0;0,0,0;-0.7071068,0,-0.7071068;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;903;1573.081,1042.498;Inherit;False;FLOAT3;0;2;1;2;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;708;1559.821,826.8126;Float;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;714;1736.664,1239.535;Float;False;Global;WindSpeedFloat;WindSpeedFloat;3;0;Create;True;0;0;False;0;2;2;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;904;1782.698,1043.837;Inherit;False;World;Object;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;912;1843.323,822.5116;Inherit;False;FLOAT2;0;2;1;2;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;911;2036.695,1180.039;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PannerNode;706;2281.074,832.8488;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleNode;858;2483.791,832.8536;Inherit;False;0.25;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;859;2347.835,975.2278;Float;False;Global;WindTurbulenceFloat;WindTurbulenceFloat;4;0;Create;True;0;0;False;0;0.25;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;860;2660.346,830.7092;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;712;2822.155,824.1631;Inherit;True;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;916;2216.165,1816.814;Inherit;False;826.1409;670.8705;Vertex Animation;8;754;886;755;914;884;744;883;743;Vertex Animation;0,1,0.8708036,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;917;3103.931,823.0183;Float;False;worldNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;918;1969.307,2128.113;Inherit;False;917;worldNoise;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;883;2268.303,2296.417;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;743;2264.894,1888.253;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;920;1920.928,239.701;Inherit;False;1121.193;358.2535;Snow;5;925;924;923;922;921;Snow;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;744;2543.398,1977.576;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;921;2043.259,294.9671;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;905;2651.922,1465.59;Inherit;False;398.5992;284.1141;Strenght Noise;2;908;906;Strenght Noise;1,0.6156863,0,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;884;2546.42,2249.673;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;755;2544.601,1884.568;Float;False;Property;_WindStrenght;Wind Strenght;4;0;Create;True;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;886;2731.664,2099.24;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;914;2548.44,2358.604;Float;False;Global;WindStrenghtFloat;WindStrenghtFloat;3;0;Create;True;0;0;False;0;0.5;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;906;2672.417,1514.806;Inherit;False;1;0;FLOAT;0.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;922;2298.01,336.7331;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;754;2892.713,2077.011;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;923;1956.837,475.8689;Inherit;False;Global;SnowBranchesFloat;SnowBranchesFloat;4;0;Create;True;0;0;False;0;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;908;2841.773,1517.078;Inherit;True;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;924;2497.963,345.3517;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;292;3510.887,809.3242;Float;False;Property;_Color;Color;0;0;Create;True;0;0;False;0;1,1,1,1;0.5943396,0.4073366,0.3055802,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;910;3162.084,1521.77;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;925;2710.791,448.7266;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;97;3423.156,995.171;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;False;0;None;e632c8e2a28f7e445a58672b91bfd65e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;293;3838.741,920.5143;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;926;3792.22,436.2442;Inherit;False;Property;_Snow;Snow;2;0;Create;True;0;0;False;0;1;1;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;900;3414.625,1327.067;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;913;3584.604,1327.308;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;927;4090.511,899.4371;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;915;3808.428,1301.797;Float;False;Property;_Wind;Wind;3;0;Create;True;0;0;False;0;0;1;1;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;928;4324.598,1053.378;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;4501.653,1052.512;Float;False;True;2;;0;0;Lambert;IL3DN/Branch;False;False;False;False;False;False;True;False;True;False;False;False;True;False;False;False;True;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;9;d3d9;d3d11_9x;d3d11;glcore;gles;gles3;metal;xboxone;ps4;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;1;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;903;0;902;0
WireConnection;904;0;903;0
WireConnection;912;0;708;0
WireConnection;911;0;904;0
WireConnection;911;1;714;0
WireConnection;706;0;912;0
WireConnection;706;2;911;0
WireConnection;858;0;706;0
WireConnection;860;0;858;0
WireConnection;860;1;859;0
WireConnection;712;0;860;0
WireConnection;917;0;712;0
WireConnection;744;0;743;4
WireConnection;744;1;918;0
WireConnection;884;0;918;0
WireConnection;884;1;883;2
WireConnection;886;0;744;0
WireConnection;886;1;884;0
WireConnection;922;0;921;2
WireConnection;754;0;755;0
WireConnection;754;1;886;0
WireConnection;754;2;914;0
WireConnection;908;0;906;0
WireConnection;924;0;922;0
WireConnection;910;0;908;0
WireConnection;910;1;754;0
WireConnection;925;0;924;0
WireConnection;925;1;923;0
WireConnection;293;0;292;0
WireConnection;293;1;97;0
WireConnection;926;0;925;0
WireConnection;900;0;910;0
WireConnection;900;1;902;0
WireConnection;913;0;900;0
WireConnection;927;0;926;0
WireConnection;927;1;293;0
WireConnection;915;0;913;0
WireConnection;928;0;927;0
WireConnection;0;0;928;0
WireConnection;0;11;915;0
ASEEND*/
//CHKSM=8118B883C6527BA81F0C71A70166F50769218C35