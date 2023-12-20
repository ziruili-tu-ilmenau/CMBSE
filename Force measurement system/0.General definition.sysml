package OEMGeneralDefinition{
	import ISQ::*;
	import SI::*;
	import ScalarValues::*;
    package GeneralPartDefinition{
    	import GeneralPortDefinition::*;
        part def OverallSystem{
            attribute maintenanceTime: Time::DateTime; 
            port MessResultPort:MeasuringInfoPort;
            port temperaturePort:TemperaturePort;
            port massPort:MassPort;
            perform action ForceMeasurement;
        }
        part def LoadCell{
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
            port InputmassPort:MassPort;
            port InputEnergyPort:EnergyPort;
		}
        part def MeasuringRing{}
        part def EnergySystem{
            port OutputEnergyPort:~EnergyPort;
	    }
    }
    package GeneralPortDefinition{
        port def MeasuringInfoPort { 
            out MessData :> ISQ::mass;
                }
        port def EnergyPort { 
            in inputVoltage :> ISQ::voltage;
                }
        port def TemperaturePort { 
            in Roomtemperature :> ISQ::temperature;
                }
        port def MassPort { 
		    in inputMass :> ISQ::mass;
		}	
	}
    package GeneralInterfaceDefinition{
    	import GeneralPortDefinition::*;
        interface def MessDataInterface{
            end p1:MeasuringInfoPort;
            end p2:~MeasuringInfoPort;
            flow p1.MessData to p2.MessData;
        }
        interface def EnergyInterface{
            end p1:EnergyPort;
            end p2:~EnergyPort;
            flow p2.inputVoltage to p1.inputVoltage;
        }
        interface def TemperatureInterface{
            end p1:TemperaturePort;
            end p2:~TemperaturePort;
            flow p2.Roomtemperature to p1.Roomtemperature;
        }
    }
    package GeneralItemDefinition{
        item def MeasuringObject;
    }
    package GeneralActionDefinition{
        action def ForceMeasurement{
            in voltageEnergy:>ISQ::voltage;
            in item measuringObject: GeneralItemDefinition::MeasuringObject;
            out messresult:>ISQ::mass;    
        }
    }
    package GeneralRequirementDefinition{
        requirement def TemperatureRequirement{
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
        requirement def MeasurementRequirement {
            doc /* The overall system should provide a certain static measurement range in the direction of gravity and a certain dynamic measurement range. */
            
            attribute staticLoadRequired:>ISQ::force;
            attribute dynamicLoadRequired:>ISQ::force;
            attribute LoadAllowed:>ISQ::force;
            require constraint {LoadAllowed>=staticLoadRequired+dynamicLoadRequired}
            }
        requirement def AccuracyRequirement {
            doc /* The overall system should provide a certain static measurement Accuracy. */
            attribute AccuracyClass:String;
            attribute AccuracyClassActual:String;
            require constraint {AccuracyClass==AccuracyClassActual}
            }
    }
}