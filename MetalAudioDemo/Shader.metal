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

//fragment float4 fragmentShader(RasterizerData in [[ stage_in ]],
//                               texture2d<half> colorTexture [[ texture(0) ]]) {
//    constexpr sampler textureSampler (mag_filter::linear,
//                                      min_filter::linear);
//    const half4 colorSample = colorTexture.sample(textureSampler, in.textureCoordinate);
//    return float4(colorSample);
//}

fragment float4 fragmentShader(RasterizerData in [[ stage_in ]],
                               texture2d<half> colorTexture [[ texture(0) ]],
                               texture2d<half> lutTexture [[ texture(1) ]]) {
    constexpr sampler sampler (mag_filter::linear,
                                      min_filter::linear);
    // 原图的色值
    const half4 colorSample = colorTexture.sample(sampler, in.textureCoordinate);
    // 原图的blue值*63，找到图中的小方块，为后续找rg准备
    float blue = colorSample.b * 63;
    
    // 找到下限和上限的小方格
    float2 quad1;
    quad1.y = floor(floor(blue) * 0.125);
    quad1.x = floor(blue) - quad1.y * 8;
    
    float2 quad2;
    quad2.y = floor(ceil(blue) * 0.125);
    quad2.x = ceil(blue) - quad2.y * 8;
    
    // 同上，两个小方格的具体像素点在整个图片的坐标
    float2 texPos1;
    texPos1.x = (quad1.x * 64 + colorSample.r * 63)/512;
    texPos1.y = (quad1.y * 64 + colorSample.g * 63)/512;
    
    float2 texPos2;
    texPos2.x = (quad2.x * 64 + colorSample.r * 63)/512;
    texPos2.y = (quad2.y * 64 + colorSample.g * 63)/512;
    
    // 查找到两个颜色并混合
    half4 newColor1 = lutTexture.sample(sampler, texPos1);
    half4 newColor2 = lutTexture.sample(sampler, texPos2);
    
    half4 res = mix(newColor1, newColor2, fract(blue));
    
    return float4(res);
}
