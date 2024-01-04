package SystemImplemetation{
    package ForceMeasurementSystemDefinition{
        import ISQ::*;
        import SI::*;
        import ScalarValues::*;
        import Quantities::*;
        import ForceMeasurementSystemPartDefinition::*;
        import ForceMeasurementSystemPortDefinition::*;
        import ForceMeasurementSystemSignalDefinition::*;
        import ForceMeasurementSystemActionDefinition::*;
        import ForceMeasurementSystemInterfaceDefinition::*;
        package ForceMeasurementSystemPartDefinition{
            part def def_ForceMeasurementSystem{
                attribute Loadcellnumber:Real;
                attribute time: Time::DateTime; 
                port port_MessResult:def_port_MeasuringInfo;
                port port_temperature:def_port_Temperature;
                perform action act_ForceMeasurement;
                exhibit state MeasuringSystemState parallel{
                    
                    state MeasuringState{
                        state st_on{
                            entry action initial;
                            state st_standby;                    
                            state st_Measurement{
                                do act_ForceMeasurement;
                            }
                            transition  initial then st_standby;
                            transition standby_to_Measurement
                                first st_standby
                                accept measureCmd
                                then st_Measurement;
                                
                            transition st_Measurement then st_standby;
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
                    state st_CheckingMonitor{
                        doc /*check if the system is normal or needs maintenance */
                    }
                }
            }
            part def def_LoadCell{
                attribute mass :> ISQ::mass;
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
                attribute limitedLateralLoad:>ISQ::force;
                attribute maintenanceTime: Time::DateTime; 
                attribute inputvoltage:>ISQ::voltage;
                attribute AccuracyClass:String;
                port port_temperature:def_port_Temperature;
                port port_energy:def_port_Energy;
                port port_mass:def_port_Mass;
                port port_Measuringinfo:def_port_MeasuringInfo;
                perform action act_ForceMeasurement_loadcell;
                exhibit state Loadcellstate parallel{
                    state MeasurementState{
                        state st_on{
                            entry action initial;
                            state st_standby;
                            state st_Measurement{
                                do act_ForceMeasurement_loadcell;
                            }
                            transition  initial then st_standby;
                            transition standby_to_Measurement
                                first st_standby
                                accept measureCmd_loadcell
                                then st_Measurement;
                                
                            transition st_Measurement then st_standby;
                        }
                        state st_off;
                        transition on_to_off
                            first st_on
                            accept OffSignal
                            then st_off;
                        transition off_to_on
                            first st_off
                            accept OnSignal
                            then st_on;
                    }
                    state st_CheckingMonitor{
                        doc /*check if the system is normal or needs maintenance */
                    }
                }
            }
            part def def_StrainGauge{
                attribute Material:String;
            }
            part def def_Body{}
            part def def_MeasuringRing{}
            part def def_EnergySystem{
                perform action act_provideEnergy;
                port port_OutputEnergy:~def_port_Energy;
            }

        }
        package ForceMeasurementSystemPortDefinition{
            port def def_port_MeasuringInfo { 
                out MessData :> ISQ::mass;
                millivolt :> scalarQuantities = ISQ::voltage*1000;
                    }
            port def def_port_Energy { 
                in inputVoltage :> ISQ::voltage;
                    }
            port def def_port_Temperature { 
                in Roomtemperature :> ISQ::temperature;
                    }
            port def def_port_Mass {
                in item Meausringobject:ItemDefinition::def_MeausringObject;
            }
            }
        package ForceMeasurementSystemSignalDefinition{
            attribute def SystemOffSignal;
            attribute def SystemOnSignal;
            attribute def measureCmd;
            attribute def OffSignal;
            attribute def OnSignal;
            attribute def measureCmd_loadcell;
        }
        package ForceMeasurementSystemInterfaceDefinition{
            interface def def_EnergyInterface{
                end p1:def_port_Energy;
                end p2:~def_port_Energy;
                flow p2.inputVoltage to p1.inputVoltage;
            }
            interface def def_MessDataInterface{
                end p1:def_port_MeasuringInfo;
                end p2:~def_port_MeasuringInfo;
                flow p1.MessData to p2.MessData;
            }
            interface def def_TemperatureInterface{
                end p1:def_port_Temperature;
                end p2:~def_port_Temperature;
                flow p2.Roomtemperature to p1.Roomtemperature;
            }
        }
        package ForceMeasurementSystemStateDefinition{
            state def def_MeasuringSystemState;
            state def def_Loadcellstate;
        }
        package ForceMeasurementSystemActionDefinition{
            action def def_act_provideEnergy{
                out voltageEnergy:>ISQ::voltage;
            }
            action def def_act_ForceMeasurement{
                in voltageEnergy:>ISQ::voltage;
                out messresult:ISQ::MassValue;
            }
            action def def_act_ForceMeasurement_loadcell{
                in voltageEnergy:>ISQ::voltage;
                in item Meausringobject:ItemDefinition::def_MeausringObject;
                out messresult:ISQ::MassValue;
            }
        }
        package ItemDefinition{
            item def def_MeausringObject{
                attribute ObjectMass:>ISQ::mass;
            }
       	}
        package ForceMeasurementSystemRequirementDefinition{
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
    package SystemImplemetationModel{
        import ForceMeasurementSystemDefinition::*;
        package PartsTree{
            part Forcemeasurementsystem_v1 : def_ForceMeasurementSystem{
                
                attribute num redefines ForceMeasurementSystemPartDefinition::def_ForceMeasurementSystem::Loadcellnumber=3;
                perform ActionTree::act_ForceMeasurement redefines act_ForceMeasurement;
                exhibit state MeasuringSystemState redefines MeasuringSystemState;
                    
                part loadcell_v1:def_LoadCell{
                    attribute loadcellMass redefines def_LoadCell::mass=2[kg];
                    attribute loadcellTmax redefines def_LoadCell::Tmax=60['°C'];
                    attribute loadcellTmin redefines def_LoadCell::Tmin=-10['°C'];
                    attribute loadcellTamax redefines def_LoadCell::Tamax=65['°C'];
                    attribute loadcellTamin redefines def_LoadCell::Tamin=-15['°C'];
                    attribute  redefines def_LoadCell::maintenanceTime=4000[h]; 
                    attribute  redefines def_LoadCell::inputvoltage=12[V];
                    attribute  loadcellCapacity redefines def_LoadCell::maximumCapacity=40[kg];
                    attribute loadcelLimitedLateralLoad redefines def_LoadCell::limitedLateralLoad=120[N];
                    attribute loadcellAccuracyClass redefines def_LoadCell::AccuracyClass="C3";	
                    
                    }
                part Measuringring:def_MeasuringRing;
                part Energysystem:def_EnergySystem{
                    perform ActionTree::act_provideEnergy redefines act_provideEnergy;
                    
                }
                interface energyInterface_v1:def_EnergyInterface
                    connect Energysystem.port_OutputEnergy to loadcell_v1.port_energy;
                interface TemperatureInterface_v1:def_TemperatureInterface
                    connect Forcemeasurementsystem_v1.port_temperature to loadcell_v1.port_temperature;
                interface MessDataInterface:def_MessDataInterface
                    connect loadcell_v1.port_Measuringinfo to Forcemeasurementsystem_v1.port_MessResult;

                satisfy requirements::temperatureRequirement by Forcemeasurementsystem_v1{
                        attribute redefines temperatureActual = Forcemeasurementsystem_v1.port_temperature.Roomtemperature;
                        attribute redefines maximumWorkingTemperature = Forcemeasurementsystem_v1.loadcell_v1.loadcellTmax;
                        attribute redefines minimumWorkingTemperature = Forcemeasurementsystem_v1.loadcell_v1.loadcellTmin;
                    
                }
                satisfy requirements::measurementRequirement by Forcemeasurementsystem_v1{
                        attribute redefines LoadAllowed = Forcemeasurementsystem_v1.num * Forcemeasurementsystem_v1.loadcell_v1.loadcellCapacity;
                }
                satisfy requirements::accuracyRequirement by Forcemeasurementsystem_v1{
                        attribute redefines AccuracyClassActual = Forcemeasurementsystem_v1.loadcell_v1.loadcellAccuracyClass;
                }
                
            }
        }
        package ActionTree{
            action act_ForceMeasurement:ForceMeasurementSystemActionDefinition::def_act_ForceMeasurement{
                in :>>voltageEnergy;
                out :>>messresult;
            }
            action act_ForceMeasurement_loadcell:ForceMeasurementSystemActionDefinition::def_act_ForceMeasurement_loadcell;
            action act_provideEnergy:ForceMeasurementSystemActionDefinition::def_act_provideEnergy;
        }
        package requirements{
            requirement temperatureRequirement:ForceMeasurementSystemRequirementDefinition::def_TemperatureRequirement{
            
            	doc /* The measuring system should run normally in certain temperature range.*/
		        attribute redefines maximumTemperature =60['°C'];
		        attribute redefines minimumTemperature=-10['°C'];
		        attribute redefines minimumWorkingTemperature;
		        attribute redefines maximumWorkingTemperature;
		        attribute redefines temperatureActual;
		        
		        require constraint {maximumTemperature>=temperatureActual}
		        require constraint {temperatureActual>=minimumTemperature}
		        require constraint {maximumWorkingTemperature>maximumTemperature}
		        require constraint {minimumTemperature>minimumWorkingTemperature}
        	}
            requirement  accuracyRequirement:ForceMeasurementSystemRequirementDefinition::def_AccuracyRequirement{
                doc /* The load cell should provide a certain static measurement Accuracy. */
                attribute redefines AccuracyClass="C3";
                attribute redefines AccuracyClassActual:String;
                require constraint {AccuracyClass==AccuracyClassActual}
            }
            requirement measurementRequirement:ForceMeasurementSystemRequirementDefinition::def_MeasurementRequirement {
                doc /* The measuring system should provide a certain static measurement range in the direction of gravity and a certain dynamic measurement range. */
                
                attribute redefines staticLoadRequired =35[kg] ;
                attribute redefines dynamicLoadRequired =1[kg];
                attribute redefines LoadAllowed;
                require constraint {LoadAllowed>=staticLoadRequired+dynamicLoadRequired}
                }
        }
    }
}
