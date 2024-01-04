package LoadCellSolution{
    package Definition{
    	import Tier1GeneralDefinition::*;
        import OEMGeneralDefinition::*;
		import Partdefinition::*;
		import PortDefinition::*;
        import InterfaceDefinition::*;
        import ActionDefinition::*;
        import SignalDefinition::*;
        import StateDefinition::*;
        import ItemDefinition::*;
        package Partdefinition{
            part def def_OverallSystem:>OEMGeneralDefinition::GeneralPartDefinition::def_OverallSystem{
                attribute Loadcellnumber:Real;
            }
            part def def_LoadCell:>Tier1GeneralDefinition::'Load Cell Part Definition'::def_loadcell;
            part def def_StrainGauge:>Tier1GeneralDefinition::'Load Cell Part Definition'::def_StrainGauge;
            part def def_MeasuringRing:>OEMGeneralDefinition::GeneralPartDefinition::def_MeasuringRing;
            part def def_EnergySystem:>OEMGeneralDefinition::GeneralPartDefinition::def_EnergySystem;
        }
        package PortDefinition{
            port def def_port_Energy:>Tier1GeneralDefinition::'Load Cell Port Definition'::def_port_Power;
        }
        package InterfaceDefinition{
            interface def def_MessDataInterface:>OEMGeneralDefinition::GeneralInterfaceDefinition::def_MessDataInterface;
            interface def def_EnergyInterface:>OEMGeneralDefinition::GeneralInterfaceDefinition::def_EnergyInterface;
            interface def def_TemperatureInterface:>OEMGeneralDefinition::GeneralInterfaceDefinition::def_TemperatureInterface;
	    }
        package ActionDefinition{
            action def def_act_ForceMeasurement:>OEMGeneralDefinition::GeneralActionDefinition::def_act_ForceMeasurement;
            action def def_act_ResultConvert{
            	millivolt :> scalarQuantities = ISQ::voltage*1000;
                in MessData:> millivolt;
                out messresult:>ISQ::mass;
            }
            action def def_act_ForceToVoltage{
                in item measuringObject:'Load Cell Item Definition'::def_MeasuringObject;
                millivolt :> scalarQuantities = ISQ::voltage*1000;
                out MessData:> millivolt;
            }
            action def def_act_ForceMeasurement_loadcell:>Tier1GeneralDefinition::'Load Cell Action Definition'::def_act_ForceMeasurement_loadcell;
        }
        package SignalDefinition{
            attribute def SystemOffSignal:>Tier1GeneralDefinition::'Load Cell Signal Definition'::SystemOffSignal;
            attribute def SystemOnSignal:>Tier1GeneralDefinition::'Load Cell Signal Definition'::SystemOnSignal;
            attribute def measureCmd:>Tier1GeneralDefinition::'Load Cell Signal Definition'::measureCmd;
        }
        package StateDefinition{
            state def def_st_Loadcell:>Tier1GeneralDefinition::'Load Cell State Definition'::def_Loadcellstate;
        }
        package ItemDefinition{
            item def def_MeasuringObject:>Tier1GeneralDefinition::'Load Cell Item Definition'::def_MeasuringObject{
                attribute ObjectMass:>ISQ::mass;
            }
        }
        package RequirementDefinition{
            requirement def def_TemperatureRequirement:> OEMGeneralDefinition::GeneralRequirementDefinition::def_TemperatureRequirement;
        	requirement def def_AccuracyRequirement:> OEMGeneralDefinition::GeneralRequirementDefinition::def_AccuracyRequirement;
            requirement def def_MeasurementRequirement:> OEMGeneralDefinition::GeneralRequirementDefinition::def_MeasurementRequirement;
        }
    }
    package LoadCellSolutionModel{
        import Definition::*;
        package PartsTree{
            part OverallSystem_v1 : Partdefinition::def_OverallSystem{
                attribute num redefines Partdefinition::def_OverallSystem::Loadcellnumber=3;
                perform ActionTree::act_ForceMeasurement redefines act_ForceMeasurement;
                part loadcell_v1:def_LoadCell{
                    attribute loadcellMass redefines mass=2[kg];
                    attribute loadcellTmax redefines Tmax=60['°C'];
                    attribute loadcellTmin redefines Tmin=-10['°C'];
                    attribute loadcellTamax redefines Tamax=65['°C'];
                    attribute loadcellTamin redefines Tamin=-15['°C'];
                    attribute  redefines maintenanceTime=4000[h]; 
                    attribute  redefines inputvoltage=12[V];
                    attribute  loadcellCapacity redefines maximumCapacity=40[kg];
                    attribute loadcellAccuracyClass redefines AccuracyClass="C3";	
                    port  port_Energy : def_port_Energy;
                    part 'Strain Gauge':'Load Cell Part Definition'::def_StrainGauge{
			 			attribute StrainGaugeMaterial:>>Material="Aluminium";
			 		}
                }
                part MeasuringRing:Partdefinition::def_MeasuringRing;
                part EnergySystem:Partdefinition::def_EnergySystem;
                interface energyInterface:InterfaceDefinition::def_EnergyInterface
                    connect EnergySystem.port_OutputEnergy to loadcell_v1.port_Energy;
                interface TemperatureInterface:InterfaceDefinition::def_TemperatureInterface
                    connect OverallSystem_v1.port_Temperature to loadcell_v1.port_temperature;
                interface MessDataInterface:InterfaceDefinition::def_MessDataInterface
                    connect loadcell_v1.port_Measuringinfo to OverallSystem_v1.port_MeasuringInfo;
                satisfy requirements::TemperatureRequirement by OverallSystem_v1{
                    requirement TemperatureRequirement :>>requirements::TemperatureRequirement{
                        attribute redefines temperatureActual = OverallSystem_v1.port_Temperature.Roomtemperature;
                        attribute redefines maximumWorkingTemperature = OverallSystem_v1.loadcell_v1.loadcellTmax;
                        attribute redefines minimumWorkingTemperature = OverallSystem_v1.loadcell_v1.loadcellTmin;
                        }
                }
                satisfy requirements::MeasurementRequirement by OverallSystem_v1{
                    requirement MeasurementRequirement :>> requirements::MeasurementRequirement{
                        attribute redefines LoadAllowed = OverallSystem_v1.num * OverallSystem_v1.loadcell_v1.loadcellCapacity;
                    }
                }
                satisfy requirements::AccuracyRequirement by OverallSystem_v1{
                    requirement AccuracyRequirement :>> requirements::AccuracyRequirement{
                        attribute redefines AccuracyClassActual = OverallSystem_v1.loadcell_v1.loadcellAccuracyClass;
                    }
                }
            }
        }
        package ActionTree{
            action act_ForceMeasurement:ActionDefinition::def_act_ForceMeasurement{
                action act_ForceMeasurement_loadcell:ActionDefinition::def_act_ForceMeasurement_loadcell{
                    action act_ResultConvert:ActionDefinition::def_act_ResultConvert;
                    action act_ForceToVoltage:ActionDefinition::def_act_ForceToVoltage;
                    flow act_ForceToVoltage.MessData to act_ResultConvert.MessData;
                    bind act_ResultConvert.messresult = act_ForceMeasurement.messresult;
                }
            }
        }
        package requirements{
            requirement TemperatureRequirement: RequirementDefinition::def_TemperatureRequirement{
            
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
        	
        	
            requirement MeasurementRequirement: RequirementDefinition::def_MeasurementRequirement {
                doc /* The measuring system should provide a certain static measurement range in the direction of gravity and a certain dynamic measurement range. */
                
                attribute redefines staticLoadRequired =35[kg] ;
                attribute redefines dynamicLoadRequired =1[kg];
                attribute redefines LoadAllowed;
                require constraint {LoadAllowed>=staticLoadRequired+dynamicLoadRequired}
            
                }
            requirement  AccuracyRequirement:'Requirement Definition'::def_AccuracyRequirement{
                doc /* The load cell should provide a certain static measurement Accuracy. */
                attribute redefines AccuracyClass="C3";
                attribute redefines AccuracyClassActual:String;
                require constraint {AccuracyClass==AccuracyClassActual}
            }
        }
    }
}