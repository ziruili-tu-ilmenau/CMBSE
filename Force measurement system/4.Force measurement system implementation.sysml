package SystemImplemetation{
    package ForceMeasurementSystemDefinition{
        import ISQ::*;
        import SI::*;
        import ScalarValues::*;
        import Quantities::*;
        import ForceMeasurementSystemPartDefinition::*;
        import ForceMeasurementSystemPortDefinition::*;
        import ForceMeasurementSystemSignalDefinition::*;

        package ForceMeasurementSystemPartDefinition{
            part def ForceMeasurementSystem{
                attribute Loadcellnumber:Real;
                attribute maintenanceTime: Time::DateTime; 
                port MessResultPort:MeasuringInfoPort;
                port temperaturePort:TemperaturePort;
                perform action ForceMeasurement;
                exhibit state MeasuringSystemState parallel{
                    
                    state MeasuringState{
                        state on{
                            entry action initial;
                            state standby;                    
                            state Measurement{
                                do ForceMeasurement;
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
            part def LoadCell{
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
                port RoomtemperaturePort:TemperaturPorte;
                port powerPort:EnergyPort;
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
                                accept measureCmd_loadcell
                                then Measurement;
                                
                            transition Measurement then standby;
                        }
                        state off;
                        transition on_to_off
                            first on
                            accept OffSignal
                            then off;
                        transition off_to_on
                            first off
                            accept OnSignal
                            then on;
                    }
                    state MaintanceState{}
                }
            }
            part def StrainGauge{
                attribute Material:String;
            }
            part def Body{}
            part def MeasuringRing{}
            part def EnergySystem{
                perform action provideEnergy;
                port OutputEnergy:~Energy;
            }

        }
        package ForceMeasurementSystemPortDefinition{
            port def MeasuringInfoPort { 
                out MessData :> ISQ::mass;
                millivolt :> scalarQuantities = ISQ::voltage*1000;
                    }
            port def EnergyPort { 
                in inputVoltage :> ISQ::voltage;
                    }
                    
            port def TemperaturePort { 
                in Roomtemperature :> ISQ::temperature;
                    }
            port def MassPort {
                in item Meausringobject:ItemDefinition::MeausringObject;
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
            interface def EnergyInterface{
                end p1:Energy;
                end p2:~Energy;
                flow p2.inputVoltage to p1.inputVoltage;
            }
            interface def MessDataInterface{
                end p1:MeasuringInfo;
                end p2:~MeasuringInfo;
                flow p1.MessData to p2.MessData;
            }
            interface def TemperatureInterface{
                end p1:Temperature;
                end p2:~Temperature;
                flow p2.Roomtemperature to p1.Roomtemperature;
            }
        }
        package ForceMeasurementSystemStateDefinition{
            state def MeasuringSystemState;
            state def Loadcellstate;
        }
        package ForceMeasurementSystemActionDefinition{
            action def provideEnergy{
                out voltageEnergy:>ISQ::voltage;
            }
            action def ForceMeasurement{
                in voltageEnergy:>ISQ::voltage;
                out messresult:ISQ::MassValue;
            }
            action def ForceMeasurement_loadcell{
                in voltageEnergy:>ISQ::voltage;
                in item Meausringobject:ItemDefinition::MeausringObject;
                out messresult:ISQ::MassValue;
            }
        }
        package ItemDefinition{
            item def MeausringObject;
       	}
        package ForceMeasurementSystemRequirementDefinition{
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
    package SystemImplemetationModel{
        import ForceMeasurementSystemDefinition::*;
        package PartsTree{
            part Forcemeasurementsystem_v1 : ForceMeasurementSystem{
                
                attribute num redefines ForceMeasurementSystemPartDefinition::ForceMeasurementSystem::Loadcellnumber=3;
                attribute  redefines ForceMeasurementSystem::maintenanceTime=3600[h]; 
                port messResultPort:~MeasuringInfoPort;
                port temperaturePort: TemperaturePort;
                perform ActionTree::ForceMeasurement redefines ForceMeasurement;
                exhibit state MeasuringSystemState redefines MeasuringSystemState;
                    
                part loadcell_v1:LoadCell{
                    attribute loadcellMass redefines LoadCell::mass=2[kg];
                    attribute loadcellTmax redefines LoadCell::Tmax=60['°C'];
                    attribute loadcellTmin redefines LoadCell::Tmin=-10['°C'];
                    attribute loadcellTamax redefines LoadCell::Tamax=65['°C'];
                    attribute loadcellTamin redefines LoadCell::Tamin=-15['°C'];
                    attribute  redefines LoadCell::maintenanceTime=4000[h]; 
                    attribute  redefines LoadCell::inputvoltage=12[V];
                    attribute  loadcellCapacity redefines LoadCell::maximumCapacity=40[kg];
                    attribute loadcelLimitedLateralLoad redefines LoadCell::limitedLateralLoad=120[N];
                    attribute loadcellAccuracyClass redefines LoadCell::AccuracyClass="C3";	
                    port messinfoPort:MeasuringInfoPort;
                    port  energyPort : EnergyPort;
                    port temperaturePort: TemperaturePort;
                    }
                part Measuringring:MeasuringRing;
                part Energysystem:EnergySystem{
                    perform ActionTree::provideEnergy redefines provideEnergy;
                    port outputenergyPort:~EnergyPort;
                }
                interface energyInterface:ForceMeasurementSystemInterfaceDefinition::EnergyInterface
                    connect Energysystem.outputenergyPort to loadcell_v1.energyPort;
                interface TemperatureInterface:InterfaceDefinition::TemperatureInterface
                    connect Forcemeasurementsystem_v1.temperaturePort to loadcell_v1.temperaturePort;
                bind loadcell_v1.messinfoPort = Forcemeasurementsystem_v1.messResultPort;
                satisfy requirements::TemperatureRequirement by Forcemeasurementsystem_v1{
                    requirement TemperatureRequirement :>>requirements::TemperatureRequirement{
                        attribute redefines temperatureActual = Forcemeasurementsystem_v1.temperaturePort.Roomtemperature;
                        attribute redefines maximumWorkingTemperature = Forcemeasurementsystem_v1.loadcell_v1.loadcellTmax;
                        attribute redefines minimumWorkingTemperature = Forcemeasurementsystem_v1.loadcell_v1.loadcellTmin;
                        }
                }
                satisfy requirements::MeasurementRequirement by Forcemeasurementsystem_v1{
                    requirement MeasurementRequirement :>> requirements::MeasurementRequirement{
                        attribute redefines LoadAllowed = Forcemeasurementsystem_v1.num * Forcemeasurementsystem_v1.loadcell_v1.loadcellCapacity;
                    }
                }
                satisfy requirements::AccuracyRequirement by Forcemeasurementsystem_v1{
                    requirement AccuracyRequirement :>> requirements::AccuracyRequirement{
                        attribute redefines AccuracyClassActual = Forcemeasurementsystem_v1.loadcell_v1.loadcellAccuracyClass;
                    }
                }
                
            }
        }
        package ActionTree{
            action ForceMeasurement:ForceMeasurementSystemActionDefinition::ForceMeasurement{
                in :>>voltageEnergy;
                out :>>messresult;
            }
            action ForceMeasurement_loadcell:ForceMeasurementSystemActionDefinition::ForceMeasurement_loadcell;
            action provideEnergy:ForceMeasurementSystemActionDefinition::provideEnergy;
        }
        package requirements{
            requirement TemperatureRequirement: ForceMeasurementSystemRequirementDefinition::Temperature{
            
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
            requirement  AccuracyRequirement:'Requirement Definition'::AccuracyRequirement{
                doc /* The load cell should provide a certain static measurement Accuracy. */
                attribute redefines AccuracyClass="C3";
                attribute redefines AccuracyClassActual:String;
                require constraint {AccuracyClass==AccuracyClassActual}
            }
            requirement MeasurementRequirement: RequirementDefinition::MeasurementRequirement {
                doc /* The measuring system should provide a certain static measurement range in the direction of gravity and a certain dynamic measurement range. */
                
                attribute redefines staticLoadRequired =35[kg] ;
                attribute redefines dynamicLoadRequired =1[kg];
                attribute redefines LoadAllowed;
                require constraint {LoadAllowed>=staticLoadRequired+dynamicLoadRequired}
                }
        }
    }
}
