//***************************************************************************************
// color.hlsl 
//
// Transforms and colors geometry.

//SV_POSITION must be declared in VS if there is no Geometry shader because the hardware 
//Expects the verticies to be in homogenous clip space. If there is a GS, This action can 
//Be deffered to that shader

//VS or GS does not do perspective divide it just does the projection matrix part, hardware takes care of it later.
//***************************************************************************************

cbuffer cbPerObject : register(b0)
{
	float4x4 gWorldViewProj; 
    float4 gPulseColor;
	float gTime;
};


struct VertexIn
{
	float3 PosL  : POSITION;
    float4 Color : COLOR;
};

struct VertexOut
{
	float4 PosH  : SV_POSITION;
    float4 Color : COLOR;
};

VertexOut VS(VertexIn vin)
{
	VertexOut vout;
	
    //Ocillate the Cube over time.
	vin.PosL.xy += 0.5f*sin(vin.PosL.x)*sin(3.0f*gTime);
	vin.PosL.z *= 0.6f + 0.4f*sin(2.0f*gTime);

	// Transform to homogeneous clip space.
	vout.PosH = mul(float4(vin.PosL, 1.0f), gWorldViewProj);
	
	// Just pass vertex color into the pixel shader.
    vout.Color = vin.Color;
    
    return vout;
}

float4 PS(VertexOut pin) : SV_Target
{
    const float pi = 3.14159; //PI constant

    //Oscilate a value in [0, 1] over time using a sine function.
    //Amplitude * sin, the roll of the wave is slowed down by multiplying pi by a small number. adding at the end extends the peak of the wave
    float s = 0.5f * sin(2 * gTime - 0.25f * pi) + 0.5f;

    //Linearly Interpolate between pin.Color and gPulseColor based on parameter s
    float4 c = lerp(pin.Color, gPulseColor, s);
    return c;
}


