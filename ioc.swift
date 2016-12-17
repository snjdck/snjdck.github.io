
public protocol IInjectable
{
	func onInject(_ injector:Injector)
}

public protocol IInjectionType : class
{
	func getValue(_ injector:Injector, _ id:String?) -> AnyObject
}

private class InjectionTypeValue
{
	unowned let realInjector:Injector
	var needInject:Bool
	
	init(_ realInjector:Injector, _ needInject:Bool)
	{
		self.realInjector = realInjector
		self.needInject = needInject
	}
	
	func doInject(_ value:AnyObject) -> AnyObject
	{
		if needInject {
			realInjector.injectInto(value)
			needInject = false
		}
		return value
	}
}

private class InjectionTypeValueStrong : InjectionTypeValue, IInjectionType
{
	let value:AnyObject
	
	init(_ value:AnyObject, _ realInjector:Injector, _ needInject:Bool)
	{
		self.value = value
		super.init(realInjector, needInject)
	}
	
	func getValue(_ injector:Injector, _ id:String?) -> AnyObject
	{
		return doInject(value)
	}
}

private class InjectionTypeValueWeak : InjectionTypeValue, IInjectionType
{
	unowned let value:AnyObject
	
	init(_ value:AnyObject, _ realInjector:Injector, _ needInject:Bool)
	{
		self.value = value
		super.init(realInjector, needInject)
	}
	
	func getValue(_ injector:Injector, _ id:String?) -> AnyObject
	{
		return doInject(value)
	}
}

private class InjectionTypeClass<T> : IInjectionType
{
	unowned let realInjector:Injector
	let cls:() -> T
	
	init(_ cls: @escaping () -> T, _ realInjector: Injector)
	{
		self.realInjector = realInjector
		self.cls = cls
	}
	
	func getValue(_ injector:Injector, _ id:String?) -> AnyObject
	{
		let value = cls() as AnyObject
		realInjector.injectInto(value)
		return value
	}
}

private class InjectionTypeSingleton<T> : InjectionTypeClass<T>
{
	var val:AnyObject?
	
	override func getValue(_ injector:Injector, _ id:String?) -> AnyObject
	{
		if val == nil {
			val = super.getValue(injector, id)
		}
		return val!
	}
}

public final class Injector
{
	public var parent:Injector?
	private var ruleDict = [String:IInjectionType]()
	
	public init(_ parent:Injector? = nil)
	{
		self.parent = parent
	}
	
	deinit {
		print("Injector deinit")
	}
	
	private func getKey<T>(_ cls:T.Type, _ id:String?) -> String
	{
		return id != nil ? "\(T.self)@\(id!)" : "\(T.self)"
	}
	
	private func getInjectionType(_ key:String) -> IInjectionType?
	{
		if let injectionType = ruleDict[key] {
			return injectionType
		}
		if let parent = parent {
			return parent.getInjectionType(key)
		}
		return nil
	}
	
	public func getInstance<T>(_ key:T.Type, id:String? = nil) -> T?
	{
		if let rule = getInjectionType(getKey(key, id)) {
			return (rule.getValue(self, id) as! T)
		}
		return nil
	}
	
	public func injectInto(_ target:Any)
	{
		if let target = target as? IInjectable {
			target.onInject(self)
		}
	}
	
	public func unmap<T>(_ key:T.Type, id:String?)
	{
		ruleDict.removeValue(forKey: getKey(key, id))
	}
	
	public func mapRule<T>(_ key:T.Type, _ value:IInjectionType, id:String?)
	{
		ruleDict[getKey(key, id)] = value
	}
	
	public func mapValue<T:AnyObject>(_ key:T.Type, _ value:T, needInject:Bool = false, id:String? = nil, realInjector:Injector? = nil)
	{
		let rule = InjectionTypeValueStrong(value, realInjector ?? self, needInject)
		mapRule(key, rule, id: id)
	}
	
	public func mapValueWeak<T:AnyObject>(_ key:T.Type, _ value:T, needInject:Bool = false, id:String? = nil, realInjector:Injector? = nil)
	{
		let rule = InjectionTypeValueWeak(value, realInjector ?? self, needInject)
		mapRule(key, rule, id: id)
	}
	
	public func mapClass<T>(_ key:T.Type, _ value:@escaping () -> T, id:String? = nil, realInjector:Injector? = nil)
	{
		let rule = InjectionTypeClass(value, realInjector ?? self)
		mapRule(key, rule, id: id)
	}
	
	public func mapSingleton<T>(_ key:T.Type, _ value:@escaping () -> T, id:String? = nil, realInjector:Injector? = nil)
	{
		let rule = InjectionTypeSingleton(value, realInjector ?? self)
		mapRule(key, rule, id: id)
	}
}
