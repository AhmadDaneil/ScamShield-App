import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'scan_state.dart';
import 'package:scamshield_app/models/scan_result.dart';
import 'package:scamshield_app/services/model_service.dart';
import 'package:scamshield_app/services/database_service.dart';

class ScanCubit extends Cubit<ScanState>{
  final ModelService _modelService;
  final DatabaseService _databaseService;

  ScanCubit({
    required ModelService modelService,
    required DatabaseService databaseService,
  }) : _modelService = modelService,
       _databaseService = databaseService,
       super(ScanInitial());
  
  Future<void> analyzeText(String text) async {
    if(text.trim().isEmpty) {
      emit(const ScanError(message: 'Please enter some text to analyze.'));
      return;
    }

    if(text.trim().length < 10) {
      emit(const ScanError(message: 'Text is too short to analyze. Please enter more content.'));
      return;
    }

    emit(ScanLoading());
    try{
      final result = await _modelService.predict(text);
      await _databaseService.insertScan(result);
      emit(ScanSuccess(result: result));
    } catch (e){
      emit(ScanError(message: 'Analysis failed. Please try again.'));
    }
  }

  void reset() => emit(ScanInitial());

}