package OEMGeneralDefinition{
	import ISQ::*;
	import SI::*;
	import ScalarValues::*;
    package GeneralPartDefinition{
    	import GeneralPortDefinition::*;
        import GeneralActionDefinition::*;
        part def def_OverallSystem{
            attribute time: Time::DateTime; 
            port port_MeasuringInfo:def_port_MeasuringInfo;
            port port_Temperature:def_port_Temperature;
            port port_Mass:def_port_Mass;
            perform action act_ForceMeasurement:def_act_ForceMeasurement;
        }
        part def def_LoadCell{
            attribute mass :> ISQ::mass;
            attribute Tmax:>ISQ::temperature{
                doc /*maximum working temperature  */
            }
            attribute Tmin:>ISQ::temperature{
                doc /*minimum working temperature  */
            }
            attribute maintenanceTime: DurationValue; 
            attribute voltage:>ISQ::voltage;
            attribute maximumCapacity:>ISQ::mass;
            attribute AccuracyClass:String;
            port port_Inputmass:def_port_Mass;
            port port_InputEnergy:def_port_Energy;
		}
        part def def_MeasuringRing{}
        part def def_EnergySystem{
            port port_OutputEnergy:~def_port_Energy;
	    }
    }
    package GeneralPortDefinition{
        port def def_port_MeasuringInfo { 
            out MessData :> ISQ::mass;
                }
        port def def_port_Energy { 
            in inputVoltage :> ISQ::voltage;
                }
        port def def_port_Temperature { 
            in Roomtemperature :> ISQ::temperature;
                }
        port def def_port_Mass { 
		    in inputMass :> ISQ::mass;
		}	
	}
    package GeneralInterfaceDefinition{
    	import GeneralPortDefinition::*;
        interface def def_MessDataInterface{
            end p1:def_port_MeasuringInfo;
            end p2:~def_port_MeasuringInfo;
            flow p1.MessData to p2.MessData;
        }
        interface def def_EnergyInterface{
            end p1:def_port_Energy;
            end p2:~def_port_Energy;
            flow p2.inputVoltage to p1.inputVoltage;
        }
        interface def def_TemperatureInterface{
            end p1:def_port_Temperature;
            end p2:~def_port_Temperature;
            flow p2.Roomtemperature to p1.Roomtemperature;
        }
    }
    package GeneralItemDefinition{
        item def def_MeasuringObject;
    }
    package GeneralActionDefinition{
        action def def_act_ForceMeasurement{
            in voltageEnergy:>ISQ::voltage;
            in item measuringObject: GeneralItemDefinition::def_MeasuringObject;
            out messresult:>ISQ::mass;    
        }
    }
    package GeneralRequirementDefinition{
        requirement def def_TemperatureRequirement{
            doc /* The overall system should run normally in certain temperature range.*/
            attribute maximumTemperature:>ISQ::temperature{
                doc /*The maximum temperature in the working environment */
            }
            attribute minimumTemperature:>ISQ::temperature{
                doc /*The minimum temperature in the working environment */
            }
            attribute temperatureActual:>ISQ::temperature;
            
            attribute maximumWorkingTemperature:>ISQ::temperature{
                doc /*The overall system maximum working temperature  */
            }
            attribute minimumWorkingTemperature:>ISQ::temperature{
                doc /*The overall system minimum working temperature  */
            }
            require constraint {maximumTemperature>=temperatureActual}
            require constraint {temperatureActual>=minimumTemperature}
            require constraint {maximumWorkingTemperature>maximumTemperature}
            require constraint {minimumTemperature>minimumWorkingTemperature}
        }
        requirement def def_MeasurementRequirement {
            doc /* The overall system should provide a certain static measurement range in the direction of gravity and a certain dynamic measurement range. */
            
            attribute staticLoadRequired:>ISQ::force;
            attribute dynamicLoadRequired:>ISQ::force;
            attribute LoadAllowed:>ISQ::force;
            require constraint {LoadAllowed>=staticLoadRequired+dynamicLoadRequired}
            }
        requirement def def_AccuracyRequirement {
            doc /* The overall system should provide a certain static measurement Accuracy. */
            attribute AccuracyClass:String;
            attribute AccuracyClassActual:String;
            require constraint {AccuracyClass==AccuracyClassActual}
            }
    }
}