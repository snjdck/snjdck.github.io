//
//  main.swift
//  Test
//
//  Created by shaokai on 16/11/12.
//
//

import Foundation



/*
protocol IInjectable : class
{
	init()
}
*/

class TT
{
	var a = 1
}
func test(){
let injector:Injector = Injector()
injector.mapValueWeak(Injector.self, injector)
injector.mapSingleton(TT.self, {TT()})

let a = injector.getInstance(Injector.self)
let b = injector.getInstance(Injector.self)

let c = injector.getInstance(TT.self)
let d = injector.getInstance(TT.self)
print("\(a! === b!)")
print("\(c! === d!)")
print("\(c!.a)")

	let t = type(of: a!)
	print(a === a.self.self)
	print(t === Injector.self)
	//let v = TT()
}
test()

class A{
	static func ~= (_ b:Int, _ a:A) -> Bool
	{
		return true
	}
	
	func test(){
		print("A")
	}
}
class B : A
{
	override func test(){
		print("B")
	}
}
print(MemoryLayout<Int>.size)
print(type(of:5))
let ta:A = B()
ta.test()
print(0...100 ~= 3)
//print(ta ~= 3)
