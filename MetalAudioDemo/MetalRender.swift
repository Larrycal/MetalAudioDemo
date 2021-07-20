//
//  MetalRender.swift
//  MetalAudioDemo
//
//  Created by 柳钰柯 on 2021/7/19.
//

import Foundation
import MetalKit

class MetalRender: NSObject {
    private(set) var commandQueue: MTLCommandQueue?
    private(set) var pipelineState: MTLRenderPipelineState?
    private let device: MTLDevice
    init?(view: MTKView) {
        guard let device = view.device else { return nil }
        self.device = device
        commandQueue = device.makeCommandQueue()
        super.init()
        loadRenderPipelineState()
        loadVertices()
    }
    private var verticesBuffer: MTLBuffer?
    private var indicesBuffer: MTLBuffer?
    private var texture: MTLTexture?
}

extension MetalRender {
    func loadRenderPipelineState() {
        let defaultLib = device.makeDefaultLibrary()
        let vertexFunc = defaultLib?.makeFunction(name: "vertexShader")
        let fragmentFunc = defaultLib?.makeFunction(name: "fragmentShader")
        let psoDescriptor = MTLRenderPipelineDescriptor()
        psoDescriptor.vertexFunction = vertexFunc
        psoDescriptor.fragmentFunction = fragmentFunc
        psoDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineState = try? device.makeRenderPipelineState(descriptor: psoDescriptor)
    }
    
    func loadVertices() {
        let vertices:[Vertex] = [
            Vertex(position: vector_float3(-1, 1, 1), textureCoordinate: vector_float2(0, 0)),
            Vertex(position: vector_float3(-1, -1, 1), textureCoordinate: vector_float2(0, 1)),
            Vertex(position: vector_float3(1, -1, 1), textureCoordinate: vector_float2(1, 1)),
            Vertex(position: vector_float3(1, 1, 1), textureCoordinate: vector_float2(1, 0))
        ]
        let indices:[UInt16] = [
            0,1,2,
            0,2,3
        ]
        verticesBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: .storageModeShared)
        indicesBuffer = device.makeBuffer(bytes: indices, length: indices.count * MemoryLayout<UInt16>.stride, options: .storageModeShared)
    }
    
    func updateTexure(_ texture: MTLTexture) {
        self.texture = texture
    }
    
}

extension MetalRender: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }
    func draw(in view: MTKView) {
        guard let renderDescriptor = view.currentRenderPassDescriptor else { return }
        guard let drawable = view.currentDrawable else { return }
        guard let indicesBuffer = indicesBuffer else { return }
        guard let texture = texture else { return }
        guard let pipeline = pipelineState else { return }
        let buffer = commandQueue?.makeCommandBuffer()
        let encoder = buffer?.makeRenderCommandEncoder(descriptor: renderDescriptor)
        encoder?.setRenderPipelineState(pipeline)
        encoder?.setVertexBuffer(verticesBuffer, offset: 0, index: 0)
        encoder?.setFragmentTexture(texture, index: 0)
        encoder?.drawIndexedPrimitives(type: .triangle, indexCount: indicesBuffer.length / MemoryLayout<UInt16>.stride, indexType: .uint16, indexBuffer: indicesBuffer, indexBufferOffset: 0)
        encoder?.endEncoding()
        buffer?.present(drawable)
        buffer?.commit()
    }
}
