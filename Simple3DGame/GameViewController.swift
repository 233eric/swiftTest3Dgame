//
//  GameViewController.swift
//  Simple3DGame
//
//  Created by Eric Thai on 2018-02-03.
//  Copyright © 2018 Eric Thai. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {

    var gameView:SCNView!
    var gameScene:SCNScene!
    var cameraNode:SCNNode!
    var targetCreationTime:TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        initScene()
        initCamera()
        
    }
    func initView() {
        gameView = self.view as! SCNView
        gameView.allowsCameraControl = false
        gameView.autoenablesDefaultLighting = true
        gameView.delegate = self
    }
    
    func initScene() {
        gameScene = SCNScene()
        gameView.scene = gameScene
        gameView.backgroundColor = UIColor.white
        gameView.isPlaying = true
    }
    func initCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        cameraNode.position = SCNVector3(x: 0, y:5, z: 10)
        
        gameScene.rootNode.addChildNode(cameraNode)
    }
    
    func getRandomColor() -> UIColor {
        let randomRed:CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomBlue:CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        return UIColor(red: randomRed, green: 0, blue: randomBlue, alpha: 1.0)
    }
    
    func createTarget() {
        let geometry:SCNGeometry = arc4random_uniform(2) == 0 ? SCNSphere(radius: 1) : SCNPyramid(width: 1, height: 1, length: 1)
        
        let randomColor = arc4random_uniform(4) == 0 ? UIColor.green : getRandomColor()
        
        geometry.materials.first?.diffuse.contents = randomColor
        
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        
        if randomColor == UIColor.green {
            geometryNode.name = "friend"
        }
        else {
            geometryNode.name = "enemy"
        }
        
        gameScene.rootNode.addChildNode(geometryNode)
        
        let RandomDirection:Float = arc4random_uniform(2) == 0 ? -1.0 : 1.0
        
        let force = SCNVector3(x: RandomDirection, y: 15, z: 0)
        geometryNode.physicsBody?.applyForce(force, at: SCNVector3(x: 0.05, y: 0.05, z:0.05), asImpulse: true)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if time > targetCreationTime {
            createTarget()
            targetCreationTime = time + 0.6
        }
        cleanUp()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        
        let location = touch.location(in: gameView)
        
        let hitList = gameView.hitTest(location, options: nil)
        
        if let hitObject = hitList.first {
            let node = hitObject.node
            
            if node.name == "friend" {
                node.removeFromParentNode()
                self.gameView.backgroundColor = UIColor.white
            }
            else {
                node.removeFromParentNode()
                self.gameView.backgroundColor = UIColor.red
            }
        }
    }
    
    func cleanUp() {
        for node in gameScene.rootNode.childNodes {
            if node.presentation.position.y < -2 {
                node.removeFromParentNode()
                
            }
        }
    }
    
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
