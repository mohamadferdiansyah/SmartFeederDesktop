import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/models/water_model.dart';

class WaterContorller extends GetxController {
  final RxList<WaterModel> waterList = <WaterModel>[
    WaterModel(waterId: 'W1', name: 'Tandon A', stock: 100.0),
    WaterModel(waterId: 'W2', name: 'Tandon B', stock: 80.0),
    WaterModel(waterId: 'W3', name: 'Tandon C', stock: 90.0),
    WaterModel(waterId: 'W4', name: 'Tandon D', stock: 70.0),
    WaterModel(waterId: 'W5', name: 'Tandon E', stock: 60.0),
    WaterModel(waterId: 'W6', name: 'Tandon F', stock: 85.0),
    WaterModel(waterId: 'W7', name: 'Tandon G', stock: 98.0),
    WaterModel(waterId: 'W8', name: 'Tandon H', stock: 120.0),
    WaterModel(waterId: 'W9', name: 'Tandon I', stock: 88.0),
    WaterModel(waterId: 'W10', name: 'Tandon J', stock: 75.0),
    WaterModel(waterId: 'W11', name: 'Tandon K', stock: 110.0),
    WaterModel(waterId: 'W12', name: 'Tandon L', stock: 95.0),
    WaterModel(waterId: 'W13', name: 'Tandon M', stock: 78.0),
    WaterModel(waterId: 'W14', name: 'Tandon N', stock: 104.0),
    WaterModel(waterId: 'W15', name: 'Tandon O', stock: 115.0),
    WaterModel(waterId: 'W16', name: 'Tandon P', stock: 99.0),
    WaterModel(waterId: 'W17', name: 'Tandon Q', stock: 93.0),
    WaterModel(waterId: 'W18', name: 'Tandon R', stock: 79.0),
    WaterModel(waterId: 'W19', name: 'Tandon S', stock: 85.0),
    WaterModel(waterId: 'W20', name: 'Tandon T', stock: 102.0),
  ].obs;
}
