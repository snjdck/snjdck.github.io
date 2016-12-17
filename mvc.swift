

import Foundation

open class Application
{
	private let injector = Injector()
	private var moduleDict = Set<Module>()
	private var hasStartup = false
	
	init(){
		injector.mapValueWeak(Application.self, self)
		injector.mapValueWeak(Injector.self, injector)
	}
	
	public func regModule<T:Module>(_ moduleCls:T.Type){
		let module = T(injector)
		assert(!(hasStartup || moduleDict.contains(module)))
		injector.injectInto(module)
		moduleDict.insert(module)
	}
	
	public func startup(){
		if !hasStartup {
			onStartup()
			hasStartup = true
		}
	}
	
	private func onStartup(){
		for module in moduleDict {
			module.initAllModels()
		}
		for module in moduleDict {
			module.initAllServices()
		}
		for module in moduleDict {
			module.initAllViews()
		}
		for module in moduleDict {
			module.initAllControllers()
		}
		for module in moduleDict {
			module.onStartup()
		}
	}
}

open class Module
{
	private unowned let applicationInjector:Injector
	private let injector:Injector
	
	required public init(_ applicationInjector:Injector)
	{
		self.applicationInjector = applicationInjector
		injector = Injector(applicationInjector)
		injector.mapValueWeak(Module.self, self)
		injector.mapValueWeak(Injector.self, injector)
	}
	
	public func regService<T>(_ key:T.Type, _ value:@escaping () -> T, asLocal:Bool){
		if asLocal {
			injector.mapSingleton(key, value)
		}else{
			applicationInjector.mapSingleton(key, value, id: nil, realInjector: injector)
		}
	}
	
	func initAllModels(){
		
	}
	func initAllServices(){
		
	}
	func initAllViews(){
		
	}
	func initAllControllers(){
		
	}
	func onStartup(){
		
	}
	
}

extension Module : Hashable
{
	public static func == (_ a:Module, _ b:Module) -> Bool
	{
		return a === b
	}
	public var hashValue:Int
	{
		print("\(type(of:self))")
		return "\(type(of:self))".hashValue
	}
}
