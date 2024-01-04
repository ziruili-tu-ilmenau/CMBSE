package ForceMeasurementSystemModel{
	import ForceMeasurementSystem_v1_Definition::*;
	doc
	/*
	 * Example for the OEM developing product: Electronic measuring system
	 */
	package PartsTree{
		part FMS_v1 : FMSPartDefinition::def_FMS{
	 		attribute num redefines FMSPartDefinition::def_FMS::Loadcellnumber=3;
			perform ActionTree::act_ForceMeasurement redefines act_ForceMeasurement;
            exhibit state st_MeasuringSystem redefines st_MeasuringSystem;
			part loadcell:FMSPartDefinition::def_LoadCell{
				attribute loadcellTmax redefines FMSPartDefinition::def_LoadCell::Tmax;
				attribute loadcellTmin redefines FMSPartDefinition::def_LoadCell::Tmin;
		 		attribute  loadcellmaintenanceTime redefines FMSPartDefinition::def_LoadCell::maintenanceTime; 
		        attribute  loadcellvoltage redefines FMSPartDefinition::def_LoadCell::voltage=12[V];
                attribute  loadcellCapacity redefines FMSPartDefinition::def_LoadCell::maximumCapacity;
                attribute loadcellAccuracyClass redefines FMSPartDefinition::def_LoadCell::AccuracyClass;
                port port_temperature_lc:FMSPortDefinition::def_port_Temperature_v1;
                }
			part MeasuringRing:FMSPartDefinition::def_MeasuringRing;
			part EnergySystem:FMSPartDefinition::def_EnergySystem{
                perform ActionTree::act_ForceMeasurement.act_provideEnergy;
            }
            interface energyInterface:FMSInterfaceDefinition::def_EnergyInterface
                connect EnergySystem.port_OutputEnergy to loadcell.port_InputEnergy;
                bind loadcell.port_messinfo = FMS_v1.port_MeasuringInfo;
                bind loadcell.port_temperature_lc= FMS_v1.port_Temperature;
            satisfy requirements::TemperatureRequirement by FMS_v1{
                requirement TemperatureRequirement :>>requirements::TemperatureRequirement{
                    attribute redefines temperatureActual = FMS_v1.port_Temperature.Roomtemperature;
                    attribute redefines maximumWorkingTemperature = FMS_v1.loadcell.loadcellTmax;
                    attribute redefines minimumWorkingTemperature = FMS_v1.loadcell.loadcellTmin;
                    }
            }
            satisfy requirements::MeasurementRequirement by FMS_v1{
                requirement MeasurementRequirement :>> requirements::MeasurementRequirement{
                    attribute redefines loadallowed = FMS_v1.num * FMS_v1.loadcell.loadcellCapacity;
                }
            }
            satisfy requirements::AccuracyRequirement by FMS_v1{
                requirement AccuracyRequirement :>> requirements::AccuracyRequirement{
                    attribute redefines AccuracyClassActual = FMS_v1.loadcell.loadcellAccuracyClass;
                }
            }
	 	}
    }

    package ActionTree{
        action act_provideEnergy:FMSActionDefinition::def_act_provideEnergy{
            
        }
        action act_ForceMeasurement:FMSActionDefinition::def_act_ForceMeasurement{
            
            action act_provideEnergy;
			flow act_provideEnergy.voltageEnergy to act_ForceMeasurement.voltageEnergy;
			
        }
    }

    package requirements {
		
        requirement TemperatureRequirement: FMSRequirementDefinition::def_TemperatureRequirement{
            	doc /* The measuring system should run normally in certain temperature range.*/
		        attribute redefines maximumTemperature = 60['°C'];
		        attribute redefines minimumTemperature =-10['°C'];
        	}
        	
        	
        requirement MeasurementRequirement: FMSRequirementDefinition::def_MeasurementRequirement {
            doc /* The measuring system should provide a certain static measurement range in the direction of gravity and a certain dynamic measurement range. */
            
            attribute redefines staticLoadRequired =1000[N] ;
            attribute redefines dynamicLoadRequired =10[N];
            attribute loadallowed redefines LoadAllowed;
            require constraint {loadallowed>=staticLoadRequired+dynamicLoadRequired}
		    
        	}
        requirement AccuracyRequirement:FMSRequirementDefinition::def_AccuracyRequirement {
                doc /* The measuring system should provide a certain static measurement Accuracy. */
                attribute redefines AccuracyClass="C3";
                require constraint {AccuracyClass==AccuracyClassActual}
                }
    }
}