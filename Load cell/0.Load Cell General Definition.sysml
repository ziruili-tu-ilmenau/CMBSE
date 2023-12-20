package Tier1GeneralDefinition{
	import ScalarValues::*;
	import ISQ::*;
	import SI::*;
    import Quantities::*;

	package 'Load Cell Part Definition'{
		import 'Load Cell Port Definition'::*;
	    import 'Load Cell Action Definition'::*;
	    import 'Load Cell State Definition'::*;
	    import 'Load Cell Signal Definition'::*;
		part def loadcell{
            attribute weight :> ISQ::mass;
            attribute Tmax:>ISQ::temperature{
                doc /*maximum working temperature of load cell */
            }
            attribute Tmin:>ISQ::temperature{
                doc /*minimum working temperature of load cell */
            }
            attribute Tamax:>ISQ::temperature{
                doc /*maximum allowed storage temperature of load cell */
            }
            attribute Tamin:>ISQ::temperature{
                doc /*minimum allowed storage temperature of load cell */
            }
            attribute maximumCapacity:>ISQ::mass{
                doc /*maximum measuring capacity of load cell */
            }
            attribute maintenanceTime: Time::DateTime; 
            attribute inputvoltage:>ISQ::voltage;
            attribute AccuracyClass:String;
            port temperaturePort:TemperaturePort;
            port powerPort:PowerPort;
            port massPort:MassPort;
            port MeasuringinfoPort:MeasuringInfoPort;
            perform action ForceMeasurement_loadcell;
            exhibit state Loadcellstate parallel{
                state Measurementstate{
                    state on{
                        entry action initial;
                        state standby;
                        state Measurement{
                            do ForceMeasurement_loadcell;
                        }
                        transition  initial then standby;
						transition standby_to_Measurement
							first standby
							accept measureCmd
							then Measurement;
							
						transition Measurement then standby;
                    }
                    state off;
                    transition on_to_off
                        first on
                        accept SystemOffSignal
                        then off;
                    transition off_to_on
                        first off
                        accept SystemOnSignal
                        then on;
                }
               	state MaintanceState{}
            }
        }
		part def StrainGauge{
            attribute Material:String;
        }
		part def Body{}
    }
	package 'Load Cell Port Definition'{
        port def TemperaturePort { 
            in Roomtemperature :> ISQ::temperature;
        }
        port def PowerPort { 
            in inputVoltage :> ISQ::voltage;
        }
        port def MassPort {
            in item measuringObject:'Load Cell Item Definition'::MeasuringObject;
        }
        port def MeasuringInfoPort { 
            millivolt :> scalarQuantities = ISQ::voltage*1000;
            out MessData :> millivolt;
        }
    }	
    package 'Load Cell Item Definition'{
        item def MeasuringObject;
    }
    package 'Load Cell State Definition'{
        state def Loadcellstate;
    }
    package 'Load Cell Action Definition'{
        action def ForceMeasurement_loadcell{
			in voltageEnergy:>ISQ::voltage;
            in item measuringObject:'Load Cell Item Definition'::MeasuringObject;
			out messresult:>ISQ::mass;
        }
    }
    package 'Load Cell Signal Definition'{
		attribute def SystemOffSignal;
		attribute def SystemOnSignal;
		attribute def measureCmd;
    }
	package 'Requirement Definition'{
        requirement def Temperature{
            	doc /* The load cell should run normally in certain temperature range.*/
		        attribute maximumTemperature:>ISQ::temperature{
		        	doc /*The maximum temperature in the working environment */
		        }
		        attribute minimumTemperature:>ISQ::temperature{
		        	doc /*The minimum temperature in the working environment */
		        }
		        attribute temperatureActual:>ISQ::temperature;
		        
		        attribute maximumWorkingTemperature:>ISQ::temperature{
		        	doc /*The load cell maximum working temperature  */
		        }
		        attribute minimumWorkingTemperature:>ISQ::temperature{
		        	doc /*The load cell minimum working temperature  */
		        }
		        
		        require constraint {maximumTemperature>=temperatureActual}
		        require constraint {temperatureActual>=minimumTemperature}
		        require constraint {maximumWorkingTemperature>maximumTemperature}
		        require constraint {minimumTemperature>minimumWorkingTemperature}
		        
        	}
    	requirement def AccuracyRequirement {
                doc /* The load cell should provide a certain static measurement Accuracy. */
                attribute AccuracyClass:String;
                attribute AccuracyClassActual:String;
                require constraint {AccuracyClass==AccuracyClassActual}
                }
        	
        requirement def MeasurementRequirement {
            doc /* The load cell should provide a certain static measurement range in the direction of gravity and a certain dynamic measurement range. */
            
            attribute staticLoadRequired:>ISQ::mass;
            attribute dynamicLoadRequired:>ISQ::mass;
            attribute staticLoadAllowed:>ISQ::mass;
            
            require constraint {staticLoadAllowed>=staticLoadRequired+dynamicLoadRequired}
		    
        	}
    }
}