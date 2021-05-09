//
//  Shaders.metal
//  CreatingAndSamplingTexturesSwift
//
//  Created by Mykhailo Tymchyshyn on 04.03.2021.
//

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands
// FIXME: This types are not shared rn, because bridging headers are not supported for frameworks.
// Need a way to get around this.
#include "ShaderTypes.h"

struct RasterizerData
{
    // The  [[position]] attribute qualifier of this member indicates this value is
    // the clip space position of the vertex when this structure is returned from
    // the vertex shader
    float4 position [[position]];

    // Since this member does not have a special attribute qualifier, the rasterizer
    // will interpolate its value with values of other vaerices making up the triangle
    // and pass that interpolated value to the fragment shader for each fragment in
    // that triangle.
    float4 color;
};

// Vertex Function
vertex RasterizerData
vertexShader(uint vertexID [[ vertex_id ]],
             constant Vertex *vertexArray [[ buffer(0) ]],
             constant vector_uint2 *viewportSizePointer [[ buffer(1) ]])
{
    RasterizerData out;

    // Index into the array of positions to get the current vartex.
    //   Positions are specified in pixel dimensions (i.e. a value of 100 is 100 pixeld from the origin)
    float2 pixelSpacePosition = vertexArray[vertexID].position.xy;

    // Get the viewport size and cast to float.
    float2 viewportSize = float2(*viewportSizePointer);

    // To convert from positions in pixel space to positions in clip-space,
    // divide the pixel coordinates by half the size of the viewport.
    // Z is set to 0.0 and w to 1.0 because this is 2D sample.
    out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = pixelSpacePosition / (viewportSize / 8.0);

    // Pass the input textureCoordinate straight to the output RasterizerData.
    // This value will be interpolated with the other textureCoordinate values
    // in the vertices that make up the triangle.
    out.color = vertexArray[vertexID].color;

    return out;
}

// Fragment function
fragment float4
samplingShader(RasterizerData in [[stage_in]])
{
//    constexpr sampler textureSampler (mag_filter::linear,
//                                      min_filter::linear);

    // Sample the texture to obtain a color
//    const half4 colorSample = colorTexture.sample(textureSampler, in.textureCoordinate);

    // return the color of the texture
    return float4(in.color);
}
