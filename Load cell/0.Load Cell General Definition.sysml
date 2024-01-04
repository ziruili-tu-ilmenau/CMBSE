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
		part def def_loadcell{
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
            port port_temperature:def_port_Temperature;
            port port_power:def_port_Power;
            port port_mass:def_port_Mass;
            port port_Measuringinfo:def_port_MeasuringInfo;
            perform action act_ForceMeasurement_loadcell:def_act_ForceMeasurement_loadcell;
            exhibit state st_Loadcell parallel{
                state st_Measurement{
                    state st_on{
                        entry action initial;
                        state st_standby;
                        state st_Measuring{
                            do act_ForceMeasurement_loadcell;
                        }
                        transition  initial then st_standby;
						transition standby_to_Measurement
							first st_standby
							accept measureCmd
							then st_Measuring;
							
						transition st_Measuring then st_standby;
                    }
                    state st_off;
                    transition on_to_off
                        first st_on
                        accept SystemOffSignal
                        then st_off;
                    transition off_to_on
                        first st_off
                        accept SystemOnSignal
                        then st_on;
                }
               	state st_CheckingMonitor{}
            }
        }
		part def def_StrainGauge{
            attribute Material:String;
        }
		part def def_Body{}
    }
	package 'Load Cell Port Definition'{
        port def def_port_Temperature { 
            in Roomtemperature :> ISQ::temperature;
        }
        port def def_port_Power { 
            in inputVoltage :> ISQ::voltage;
        }
        port def def_port_Mass {
            in item measuringObject:'Load Cell Item Definition'::def_MeasuringObject;
        }
        port def def_port_MeasuringInfo { 
            millivolt :> scalarQuantities = ISQ::voltage*1000;
            out MessData :> millivolt;
        }
    }	
    package 'Load Cell Item Definition'{
        item def def_MeasuringObject;
    }
    package 'Load Cell State Definition'{
        state def def_Loadcellstate;
    }
    package 'Load Cell Action Definition'{
        action def def_act_ForceMeasurement_loadcell{
			in voltageEnergy:>ISQ::voltage;
            in item measuringObject:'Load Cell Item Definition'::def_MeasuringObject;
			out messresult:>ISQ::mass;
        }
    }
    package 'Load Cell Signal Definition'{
		attribute def SystemOffSignal;
		attribute def SystemOnSignal;
		attribute def measureCmd;
    }
	package 'Requirement Definition'{
        requirement def def_TemperatureRequirement{
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
    	requirement def def_AccuracyRequirement {
                doc /* The load cell should provide a certain static measurement Accuracy. */
                attribute AccuracyClass:String;
                attribute AccuracyClassActual:String;
                require constraint {AccuracyClass==AccuracyClassActual}
                }
        	
        requirement def def_MeasurementRequirement {
            doc /* The load cell should provide a certain static measurement range in the direction of gravity and a certain dynamic measurement range. */
            
            attribute staticLoadRequired:>ISQ::mass;
            attribute dynamicLoadRequired:>ISQ::mass;
            attribute staticLoadAllowed:>ISQ::mass;
            
            require constraint {staticLoadAllowed>=staticLoadRequired+dynamicLoadRequired}
		    
        	}
    }
}