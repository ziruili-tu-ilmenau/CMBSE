package LoadCellModel{
    import LoadCellDefinition::*;
    package PartsTree{
        part LoadCell_v1 : LoadCellDefinition::'Load Cell Part Definition'::def_loadcell{
            attribute :>>weight =2[kg];
            
            attribute :>>Tmax=60['°C'];
          
            attribute :>>Tmin=-10['°C'];
            
            attribute :>>Tamax=65['°C'];
            
            attribute :>>Tamin=-15['°C'];
            
            attribute :>>maximumCapacity=40[kg];
            
            attribute :>>maintenanceTime=4000[h]; 
            
            attribute :>>inputvoltage=12[V];
            
            attribute :>>AccuracyClass="C3";		 	
	     	
	 		part StrainGauge_v1: LoadCellDefinition::'Load Cell Part Definition'::def_StrainGauge{
	 			attribute :>>Material="Aluminium";
	 		}
            perform ActionTree::act_ForceMeasurement_loadcell redefines act_ForceMeasurement_loadcell;
            port port_MeasuringInfo: def_port_MeasuringInfo ;
            satisfy requirements::TemperatureRequirement by LoadCell_v1{
                attribute redefines maximumWorkingTemperature = LoadCell_v1.Tmax;
                attribute redefines minimumWorkingTemperature = LoadCell_v1.Tmin;
                attribute redefines temperatureActual=LoadCell_v1.port_temperature.Roomtemperature;
            }
            satisfy requirements::MeasurementRequirement by LoadCell_v1{
                attribute redefines  staticLoadAllowed = LoadCell_v1.maximumCapacity;
            }
            satisfy requirements::AccuracyRequirement by LoadCell_v1{
                    requirement AccuracyRequirement :>> requirements::AccuracyRequirement{
                        attribute redefines AccuracyClassActual = LoadCell_v1.AccuracyClass;
                    }
        }
    }
    }
    package ActionTree{
        action act_ForceMeasurement_loadcell:'Load Cell Action Definition'::def_act_ForceMeasurement_loadcell{
            action act_ResultConvert:'Load Cell Action Definition'::def_act_ResultConvert;
            action act_ForceToVoltage:'Load Cell Action Definition'::def_act_ForceToVoltage;
            flow act_ForceToVoltage.MessData to act_ResultConvert.MessData;
            flow act_ResultConvert.messresult to act_ForceMeasurement_loadcell.messresult;
        }
    }
    package requirements{
        requirement TemperatureRequirement: 'Requirement Definition'::def_TemperatureRequirement{
            
            	doc /* The measuring system should run normally in certain temperature range.*/
		        attribute redefines maximumTemperature =60['°C'];
		        attribute redefines minimumTemperature=-10['°C'];
		        attribute redefines minimumWorkingTemperature;
		        attribute redefines maximumWorkingTemperature;
		        attribute redefines temperatureActual;
		        
		        require constraint {maximumTemperature>=temperatureActual}
		        require constraint {temperatureActual>=minimumTemperature}
		        
        	}
        	
        	
        requirement MeasurementRequirement: 'Requirement Definition'::def_MeasurementRequirement {
            doc /* The measuring system should provide a certain static measurement range in the direction of gravity and a certain dynamic measurement range. */
            
            attribute redefines staticLoadRequired =35[kg] ;
            attribute redefines dynamicLoadRequired =1[kg];
            attribute redefines staticLoadAllowed{}
            require constraint {staticLoadAllowed>=staticLoadRequired+dynamicLoadRequired}
		   
        	}
        requirement  AccuracyRequirement:'Requirement Definition'::def_AccuracyRequirement{
            doc /* The load cell should provide a certain static measurement Accuracy. */
                attribute redefines AccuracyClass="C3";
                require constraint {AccuracyClass==AccuracyClassActual}
            }
    }
}