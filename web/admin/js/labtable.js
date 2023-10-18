var labsDefinitions = [
	{
		name: '<b>CBC (Hb, MCV, WBC, Plt)</b>',
		items: [
			{
				label: '<b>CBC</b>',
				unit: ''
			},
			{
				label: '     Hemoglobin',
				min: 135,
				max: 145,
				unit: 'g/L'
			},
			{
				label: '     MCV',
				min: 76,
				max: 100,
				unit: 'g/L'
			},
			{
				label: '     WBC',
				min: 3.5,
				max: 12,
				unit: 'x10^9/L',
				decimals: 1
			},
			{
				label: '     Platelets',
				min: 150,
				max: 400,
				unit: 'x10^9/L'
			}
		]
	},
	{
		name: '     Hemoglobin',
		items: [
			{
				label: 'Hemoglobin',
				min: 135,
				max: 145,
				unit: 'g/L'
			}
		]
	},
	{
		name: '     Platelets',
		items: [
			{
				label: 'Platelets',
				min: 150,
				max: 400,
				unit: 'x10^9/L'
			}
		]
	},
	{
		name: '     WBC',
		items: [
			{
				label: 'WBC',
				min: 3.5,
				max: 12,
				unit: 'x10^9/L',
				decimals: 1
			}
		]
	},
	{
		name: '    <b>Diff (x5)</b>',
		items: [
			{
				label: '   Neutrophils',
				min: 3.0,
				max: 5.8,
				unit: 'x10^9/L',
				decimals: 1
			},
			{
				label: '   Lymphocytes',
				min: 1.5,
				max: 3.0,
				unit: 'x10^9/L',
				decimals: 1
			},
			{
				label: '   Monocytes',
				min: 300,
				max: 500,
				unit: 'x10^6/L'
			},
			{
				label: '   Eosinophils',
				min: 50,
				max: 250,
				unit: 'x10^6/L'
			},
			{
				label: '   Basophils',
				min: 15,
				max: 150,
				unit: 'x10^6/L'
			}
		]
	},
	{
		name: '<b>Lytes (Na, Cl, K+, CO2)</b>',
		items: [
			{
				label: '<b>Electrolytes</b>',
				unit: ''
			},
			{
				label: '     Sodium',
				min: 135,
				max: 145,
				unit: 'mmol/L'
			},
			{
				label: '     Chloride',
				min: 96,
				max: 106,
				unit: 'mmol/L'
			},
			{
				label: '     Potassium',
				min: 3.5,
				max: 5.1,
				unit: 'mmol/L',
				decimals: 1
			},
			{
				label: '     Bicarbonate',
				min: 22,
				max: 25,
				unit: 'mmol/L'
			},
		]
	},
	{
		name: 'Creatinine',
		items: [
			{
				label: 'Creatinine',
				min: 50,
				max: 110,
				unit: 'umol/L',
				decimals: 0
			}
		]
	},
	{
		name: 'Urea',
		items: [
			{
				label: 'Urea',
				min: 4,
				max: 8.2,
				unit: 'mmol/L',
				decimals: 1
			}
		]
	},
	{
		name: '<b>Extended Lytes (Ca, Mg, Ph)</b>',
		items: [
			{
				label: '<b>Extended Electrolytes</b>',
				unit: ''
			},
			{
				label: '     Calcium',
				min: 2.1,
				max: 2.5,
				unit: 'mmol/L',
				decimals: 1
			},
			{
				label: '     Magnesium',
				min: 0.65,
				max: 1.05,
				unit: 'mmol/L',
				decimals: 2
			},
			{
				label: '     Phosphate',
				min: 1.0,
				max: 1.5,
				unit: 'mmol/L',
				decimals: 1
			}
		]
	},
	{
		name: '     Ionized Calcium',
		items: [
			{
				label: 'Ionized Ca',
				min: 2.1,
				max: 2.5,
				unit: 'mmol/L',
				decimals: 1
			},
		]
	},
	{
		name: '     Calcium',
		items: [
			{
				label: 'Calcium',
				min: 2.1,
				max: 2.5,
				unit: 'mmol/L',
				decimals: 1
			}
		]
	},
	{
		name: '     Magnesium',
		items: [
			{
				label: 'Magnesium',
				min: 0.65,
				max: 1.05,
				unit: 'mmol/L',
				decimals: 2
			}
		]
	},
	{
		name: '     Phosphate',
		items: [
			{
				label: 'Phosphate',
				min: 1.0,
				max: 1.5,
				unit: 'mmol/L',
				decimals: 1
			}
		]
	},
	{
		name: 'INR',
		items: [
			{
				label: 'INR',
				min: 0.9,
				max: 1.1,
				unit: '',
				decimals: 1
			}
		]
	},
	{
		name: 'PTT',
		items: [
			{
				label: 'PTT',
				min: 22,
				max: 37,
				unit: 'sec',
				decimals: 0
			}
		]
	},
	{
		name: 'CRP',
		items: [
			{
				label: 'CRP',
				min: 0,
				max: 3,
				unit: 'mg/L (< 3)',
				decimals: 0
			}
		]
	},
	{
		name: 'Albumin',
		items: [
			{
				label: 'Albumin',
				min: 35,
				max: 43,
				unit: 'g/L',
				decimals: 0
			}
		]
	},
	{
		name: '<b>Liver Enzymes (AST, ALT, ALP)</b>',
		items: [
			{
				label: 'AST',
				min: 10,
				max: 40,
				unit: 'IU/L',
				decimals: 0
			},
			{
				label: 'ALT',
				min: 10,
				max: 35,
				unit: 'IU/L',
				decimals: 0
			},
			{
				label: 'ALP',
				min: 40,
				max: 160,
				unit: 'IU/L',
				decimals: 0
			}
		]
	},
	{
		name: 'Lactate',
		items: [
			{
				label: 'Lactate',
				min: 0.5,
				max: 1.9,
				unit: 'mmol/L',
				decimals: 1
			}
		]
	},
	{
		name: 'CK',
		items: [
			{
				label: 'CK',
				min: 20,
				max: 215,
				unit: 'IU/L',
				decimals: 0
			}
		]
	},
	{
		name: 'Troponin',
		items: [
			{
				label: 'hs-Troponin',
				min: 3,
				max: 14,
				unit: 'ng/L (<14)',
				decimals: 0
			}
		]
	},
	{
		name: 'Troponin (3 hrs)',
		items: [
			{
				label: 'hs-Troponin',
				min: 3,
				max: 14,
				unit: 'ng/L (<14)',
				decimals: 0
			}
		]
	},
	{
		name: 'TSH',
		items: [
			{
				label: 'TSH',
				min: 0.6,
				max: 4.8,
				unit: 'mIU/L',
				decimals: 1
			}
		]
		
	},
	{
		name: 'PTH',
		items: [
			{
				label: 'PTH',
				min: 10,
				max: 65,
				unit: 'ng/L',
				decimals: 0
			}
		]
		
	},
	{
		name: 'Osmolality (serum)',
		items: [
			{
				label: 'Osmolality (serum)',
				min: 285,
				max: 295,
				unit: 'mmol/kg',
				decimals: 0
			}
		]
		
	},
	{
		name: '<b>Arterial Blod Gas</b>',
		items: [
			{
				label: '<b>Arterial Blood Gas</b>',
				unit: ''
			},
			{
				label: '     pH',
				min: 7.35,
				max: 7.43,
				unit: '',
				decimals: 2
			},
			{
				label: '     pO2',
				min: 80,
				max: 100,
				unit: 'mmHg'
			},
			{
				label: '     pCO2',
				min: 37,
				max: 43,
				unit: 'mmHg'
			},
			{
				label: '     HCO3',
				min: 23,
				max: 25,
				unit: 'mmol/L'
			}
		]
	}
];