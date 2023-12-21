111
package ExampleDefinition{
	import ISQ::*;
	import SI::*;
    part def OverallSystem{
        attribute TemperatureAttribute:> ISQ::temperature;
    }
    part def SubSystem1;
}
package ExampleUsage{
    import ExampleDefinition::*;
    part OverallSystem1:OverallSystem{
        attribute t1 redefines OverallSystem::TemperatureAttribute=20['°C'];
        part subsystem1:SubSystem1;
    }
}
