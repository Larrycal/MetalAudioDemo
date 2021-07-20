//
//  Shader.metal
//  MetalAudioDemo
//
//  Created by 柳钰柯 on 2021/7/19.
//

#include <metal_stdlib>
#include "ShaderType.h"
using namespace metal;
struct RasterizerData
{
    float4 position [[position]];
    float2 textureCoordinate;
};

vertex RasterizerData vertexShader(uint vertexID [[ vertex_id ]],
                    constant Vertex *in [[buffer(0)]]) {
    RasterizerData out;
    out.position = float4(in[vertexID].position,1);
    out.textureCoordinate = in[vertexID].textureCoordinate;
    return out;
}

fragment float4 fragmentShader(RasterizerData in [[ stage_in ]],
                               texture2d<half> colorTexture [[ texture(0) ]]) {
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear);
    const half4 colorSample = colorTexture.sample(textureSampler, in.textureCoordinate);
    return float4(colorSample);
}
