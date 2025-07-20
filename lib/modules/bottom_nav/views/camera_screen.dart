import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:calories_tracker/features/models/meal_model.dart';
import 'package:vibration/vibration.dart';
import 'package:provider/provider.dart';
import '../../../core/services/openai_service.dart';
import '../../../core/services/upload_service.dart';
import '../../../providers/dashboard_provider.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class CameraScreen extends StatefulWidget {
  final List<Meal>? meals;
  final Function(List<Meal>)? updateMeals;

  const CameraScreen({
    super.key,
    this.meals,
    this.updateMeals,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;
  bool _isFlashOn = false;

  String? _capturedImagePath;

  late AnimationController _captureAnimationController;
  late AnimationController _flashAnimationController;
  late Animation<double> _captureAnimation;
  late Animation<double> _flashAnimation;

  @override
  void initState() {
    super.initState();
    print('📷 CameraScreen initialized');
    print('📷 Received meals: ${widget.meals?.length ?? 'null'}');
    print('📷 Received updateMeals: ${widget.updateMeals != null ? 'present' : 'null'}');
    WidgetsBinding.instance.addObserver(this);
    _initializeAnimations();
    _checkPermissionsAndInitialize();
  }

  Future<void> _checkPermissionsAndInitialize() async {
    // Add a small delay to ensure the widget is fully mounted
    await Future.delayed(const Duration(milliseconds: 100));
    await _requestCameraPermissionAndInitialize();
  }

  Future<void> _requestCameraPermissionAndInitialize() async {
    try {
      print('🔍 Initializing camera directly...');
      await _initializeCamera();
    } catch (e) {
      print('❌ Error initializing camera: $e');
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _initializeAnimations() {
    _captureAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _flashAnimationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _captureAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _captureAnimationController,
      curve: Curves.easeInOut,
    ));

    _flashAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flashAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeCamera() async {
    try {
      print('📷 Initializing camera...');

      // Add a small delay to ensure proper initialization
      await Future.delayed(const Duration(milliseconds: 200));

      // Get available cameras
      _cameras = await availableCameras();
      print('📱 Found  [38;5;10m [1m${_cameras?.length ?? 0} [0m cameras');

      if (_cameras == null || _cameras!.isEmpty) {
        print('❌ No cameras available on device');
        if (mounted) {
          Navigator.of(context).pop();
        }
        return;
      }

      // Initialize camera controller with more robust settings
      final camera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      print('📸 Using camera: ${camera.name}');

      _controller = CameraController(
        camera,
        ResolutionPreset.high, // Use high resolution for better quality
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      print('🔧 Initializing camera controller...');
      await _controller!.initialize();

      // Verify camera is actually working
      if (!_controller!.value.isInitialized) {
        throw Exception('Camera failed to initialize properly');
      }

      print('✅ Camera controller initialized successfully');

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
        print('🎯 Camera UI updated');
      }
    } catch (e) {
      print('❌ Error initializing camera: $e');
      print('❌ Error details: ${e.runtimeType}');
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final newFlashMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
      await _controller!.setFlashMode(newFlashMode);
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      print('Error toggling flash: $e');
    }
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized || _isCapturing) {
      return;
    }

    try {
      setState(() {
        _isCapturing = true;
      });

      // Haptic feedback
      try {
        if (await Vibration.hasVibrator() == true) {
          Vibration.vibrate(duration: 50);
        }
      } catch (e) {
        // Ignore vibration errors
      }

      // Capture animation
      _captureAnimationController.forward().then((_) {
        _captureAnimationController.reverse();
      });

      // Flash animation for visual feedback
      _flashAnimationController.forward().then((_) {
        _flashAnimationController.reverse();
      });

      // Set flash mode for capture
      if (_isFlashOn) {
        await _controller!.setFlashMode(FlashMode.always);
      }

      final XFile image = await _controller!.takePicture();

      // Reset flash mode
      if (_isFlashOn) {
        await _controller!.setFlashMode(FlashMode.torch);
      }

      if (mounted) {
        // Add a temporary analyzing meal to show animation
        if (widget.updateMeals != null && widget.meals != null) {
          print('📸 Creating analyzing meal for captured photo');
          print('📸 Current meals count: ${widget.meals!.length}');
          final analyzingMeal = Meal.analyzing(
            imageUrl: image.path,
            localImagePath: image.path,
            userId: FirebaseAuth.instance.currentUser?.uid,
          );
          final updatedMeals = [...widget.meals!, analyzingMeal];
          print('📸 Updated meals count: ${updatedMeals.length}');
          print('📸 Calling updateMeals...');
          widget.updateMeals!(updatedMeals);
          print('📸 updateMeals called successfully');

          // Start analysis in background
          analyzeImageFile(image.path);
        }
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error capturing photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture photo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      print('📱 _pickFromGallery called');
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null && mounted) {
        print('📱 Image selected from gallery: ${image.path}');

        // Add a temporary analyzing meal to show animation
        if (widget.updateMeals != null && widget.meals != null) {
          print('📱 Creating analyzing meal for gallery image');
          print('📱 Current meals count: ${widget.meals!.length}');
          final analyzingMeal = Meal.analyzing(
            imageUrl: image.path,
            localImagePath: image.path,
            userId: FirebaseAuth.instance.currentUser?.uid,
          );
          final updatedMeals = [...widget.meals!, analyzingMeal];
          print('📱 Updated meals count: ${updatedMeals.length}');
          print('📱 Calling updateMeals...');
          widget.updateMeals!(updatedMeals);
          print('📱 updateMeals called successfully with ${updatedMeals.length} meals, ${updatedMeals.where((m) => m.isAnalyzing).length} analyzing');
          
          // Show analyzing message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🔍 Analyzing meal...'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 1),
            ),
          );

          // Start analysis in background
          analyzeImageFile(image.path);
        }
        Navigator.of(context).pop();
      } else {
        print('📱 No image selected from gallery');
      }
    } catch (e) {
      print('Error picking from gallery: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick from gallery: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> analyzeImageFile(String imagePath) async {
    try {
      print('🚀 Starting image analysis for: $imagePath');

      // Upload image and get URL with retry logic
      final imageUrl = await UploadService.uploadImageWithRetry(File(imagePath));
      print('📤 Image uploaded to: $imageUrl');

      // Get the image file name for analysis
      final imageName = imagePath.split('/').last;

      // Analyze image with OpenAI using the correct method with retry
      final analysis = await OpenAIService.analyzeMealImageWithRetry(
        imageUrl: imageUrl,
        imageName: imageName,
        imageFile: File(imagePath),
      );

      print('🎯 Analysis completed successfully');
      await _handleAnalysisResult(analysis, imageUrl);

    } catch (e) {
      print('❌ Error in image analysis: $e');

      // Find and update the analyzing meal to show failure
      if (widget.updateMeals != null && widget.meals != null) {
        // Check if widget is still mounted before proceeding
        if (!mounted) {
          print('⚠️ Widget unmounted during analysis error handling, skipping UI update');
          return;
        }
        
        final updatedMeals = widget.meals!.map((meal) {
          if (meal.isAnalyzing &&
              (meal.imageUrl == imagePath || meal.localImagePath == imagePath)) {
            return Meal.failed(
              id: meal.id,
              imageUrl: meal.imageUrl ?? imagePath,
              localImagePath: imagePath,
              userId: meal.userId,
            );
          }
          return meal;
        }).toList();

        widget.updateMeals!(updatedMeals);
        await Meal.saveToLocalStorage(updatedMeals);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleAnalysisResult(Map<String, dynamic> analysis, String imageUrl) async {
    try {
      print('🍽️ Processing analysis result for meal');
      print('🍽️ Widget mounted: $mounted');
      
      // Don't skip if widget is unmounted - we still need to update the data
      // The UI will be updated when the user returns to the dashboard
      if (!mounted) {
        print('⚠️ Widget unmounted but continuing with analysis processing for data consistency');
      }
      
      print('🍽️ Current widget.meals length: ${widget.meals?.length ?? 0}');
      final currentAnalyzingCount = widget.meals?.where((meal) => meal.isAnalyzing).length ?? 0;
      print('🍽️ Current analyzing meals count: $currentAnalyzingCount');

      if (widget.updateMeals != null) {
        List<Meal> currentMeals;
        
        // Always try to get the most current meals list
        try {
          if (mounted && context.mounted) {
            final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
            currentMeals = dashboardProvider.meals;
            print('🍽️ Getting current meals from dashboard provider: ${currentMeals.length} meals');
          } else {
            print('⚠️ Context not available, using widget.meals as fallback');
            currentMeals = widget.meals ?? [];
            
            // If widget.meals doesn't contain analyzing meals, try to find them in a different way
            final hasAnalyzingMeals = currentMeals.any((meal) => meal.isAnalyzing);
            if (!hasAnalyzingMeals) {
              print('⚠️ widget.meals missing analyzing meals, this may cause issues');
              // Try to load from local storage as a last resort
              try {
                final savedMeals = await Meal.loadFromLocalStorage();
                final recentSavedMeals = savedMeals.where((meal) => 
                  DateTime.now().difference(meal.timestamp).inMinutes < 5
                ).toList();
                if (recentSavedMeals.isNotEmpty) {
                  print('🔄 Found ${recentSavedMeals.length} recent meals in local storage');
                  currentMeals = [...currentMeals, ...recentSavedMeals.where((saved) => 
                    !currentMeals.any((current) => current.id == saved.id)
                  )];
                }
              } catch (storageError) {
                print('⚠️ Could not load from local storage: $storageError');
              }
            }
          }
        } catch (e) {
          print('⚠️ Error accessing dashboard provider: $e, using widget.meals as fallback');
          currentMeals = widget.meals ?? [];
        }
        
        final providerAnalyzingCount = currentMeals.where((meal) => meal.isAnalyzing).length;
        print('🍽️ Current meals count: ${currentMeals.length}, analyzing: $providerAnalyzingCount');
        // Find the analyzing meal and replace it with the analyzed result
        // The analyzing meal has a local path, but imageUrl parameter is Firebase Storage URL
        // We need to match by the filename instead
        final uri = Uri.parse(imageUrl);
        final decodedPath = Uri.decodeComponent(uri.path); // Decode URL encoding
        final fileName = decodedPath.split('/').last; // Get filename from path
        final baseFileName = fileName.replaceAll(RegExp(r'^\d+-'), ''); // Remove timestamp prefix
        
        print('🔍 Looking for analyzing meal to replace');
        print('🔍 Firebase URL: $imageUrl');
        print('🔍 Extracted filename: $baseFileName');
        print('🔍 Current meals count for matching: ${currentMeals.length}');
        
        // First, try to find any analyzing meal (even if filename doesn't match exactly)
        final analyzingMeals = currentMeals.where((meal) => meal.isAnalyzing).toList();
        print('🔍 Found ${analyzingMeals.length} analyzing meals in current list');
        
        bool foundMatch = false;
        Meal? targetAnalyzingMeal;
        
        // If we have exactly one analyzing meal, use it (most common case)
        if (analyzingMeals.length == 1) {
          targetAnalyzingMeal = analyzingMeals.first;
          foundMatch = true;
          print('✅ Using the only analyzing meal found: ${targetAnalyzingMeal.id}');
        } else if (analyzingMeals.length > 1) {
          // Multiple analyzing meals, try filename matching
          for (final meal in analyzingMeals) {
            final mealFileName = meal.localImagePath?.split('/').last ?? '';
            print('🔍 Checking analyzing meal: id=${meal.id}, filename=$mealFileName');
            
            if (mealFileName == baseFileName || meal.localImagePath?.contains(baseFileName) == true) {
              targetAnalyzingMeal = meal;
              foundMatch = true;
              print('✅ Found matching analyzing meal by filename: ${meal.id}');
              break;
            }
          }
          
          // If no filename match, use the most recent analyzing meal
          if (!foundMatch && analyzingMeals.isNotEmpty) {
            targetAnalyzingMeal = analyzingMeals.last;
            foundMatch = true;
            print('✅ Using most recent analyzing meal as fallback: ${targetAnalyzingMeal.id}');
          }
        }
        
        final updatedMeals = currentMeals.map((meal) {
          if (foundMatch && meal.id == targetAnalyzingMeal?.id) {
            print('✅ Replacing analyzing meal ${meal.id} with analysis result');
            // Create a new meal from the analysis using the existing meal's ID
            return Meal.fromAnalysis(
              id: meal.id,
              imageUrl: imageUrl,
              localImagePath: meal.localImagePath,
              analysisData: analysis,
              userId: FirebaseAuth.instance.currentUser?.uid ?? 'anonymous',
            );
          }
          return meal;
        }).toList();
        
          if (!foundMatch) {
            print('❌ No matching analyzing meal found, creating new completed meal instead');
            print('❌ Available meals:');
            for (int i = 0; i < currentMeals.length; i++) {
              final meal = currentMeals[i];
              print('  [$i] isAnalyzing: ${meal.isAnalyzing}, imageUrl: ${meal.imageUrl}, localPath: ${meal.localImagePath}');
            }
            
            // Create a new completed meal instead of losing the analysis
            final newMeal = Meal.fromAnalysis(
              id: const Uuid().v4(), // Generate new ID
              imageUrl: imageUrl,
              localImagePath: null,
              analysisData: analysis,
              userId: FirebaseAuth.instance.currentUser?.uid ?? 'anonymous',
            );
            
            updatedMeals.add(newMeal);
            print('✅ Added new completed meal instead: ${newMeal.id}');
          }

          // Save to local storage
          await Meal.saveToLocalStorage(updatedMeals);
          print('💾 Analysis result saved to local storage');

          // Update the UI
          widget.updateMeals!(updatedMeals);
          print('🔄 updateMeals callback called with ${updatedMeals.length} meals');
          final analyzingCountAfter = updatedMeals.where((meal) => meal.isAnalyzing).length;
          print('🔄 Meals after update: ${updatedMeals.length} total, ${analyzingCountAfter} analyzing');

        print('✅ Analysis result processed and UI updated');
        
        // Show success message only if widget is still mounted and context is available
        try {
          if (mounted && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ Meal analyzed and added successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            print('⚠️ Widget/context not available for success message, but analysis completed successfully');
          }
        } catch (e) {
          print('⚠️ Could not show success message: $e');
        }
      }
    } catch (e) {
      print('❌ Error handling analysis result: $e');

      // On error, mark the analyzing meal as failed
      if (widget.updateMeals != null) {
        List<Meal> currentMeals;
        
        // Try to get current meals, use fallback if widget is unmounted
        try {
          if (mounted && context.mounted) {
            final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
            currentMeals = dashboardProvider.meals;
          } else {
            currentMeals = widget.meals ?? [];
          }
        } catch (e) {
          currentMeals = widget.meals ?? [];
        }
        
        final updatedMeals = currentMeals.map((meal) {
          if (meal.isAnalyzing &&
              (meal.imageUrl == imageUrl || meal.localImagePath?.contains(imageUrl.split('/').last) == true)) {
              return Meal.failed(
                id: meal.id,
                imageUrl: imageUrl,
                localImagePath: meal.localImagePath,
                userId: meal.userId,
              );
            }
            return meal;
          }).toList();

        widget.updateMeals!(updatedMeals);
        await Meal.saveToLocalStorage(updatedMeals);
      }

      try {
        if (mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error processing analysis: $e'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          print('⚠️ Widget/context not available for error message, but error was handled');
        }
      } catch (errorDisplayError) {
        print('⚠️ Could not show error message: $errorDisplayError');
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _captureAnimationController.dispose();
    _flashAnimationController.dispose();
    super.dispose();
  }

  Widget _buildCameraPreview() {
    if (!_isCameraInitialized || _controller == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Simple, original camera preview - no transformations
        CameraPreview(_controller!),

        // Flash overlay for capture feedback
        AnimatedBuilder(
          animation: _flashAnimation,
          builder: (context, child) {
            return Container(
              color: Colors.white.withOpacity(_flashAnimation.value * 0.8),
            );
          },
        ),

        // Camera overlay with guides
        CustomPaint(
          painter: CameraOverlayPainter(
            Colors.white,
          ),
          size: Size.infinite,
        ),
      ],
    );
  }

  Widget _buildTopControls() {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),

          // Flash toggle
          GestureDetector(
            onTap: _toggleFlash,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: _isFlashOn ? Colors.yellow : Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Gallery button
              GestureDetector(
                onTap: _pickFromGallery,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),

              // Capture button
              GestureDetector(
                onTap: _isCapturing ? null : _capturePhoto,
                child: AnimatedBuilder(
                  animation: _captureAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _captureAnimation.value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 4,
                          ),
                        ),
                        child: _isCapturing
                            ? const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt,
                                color: Colors.black,
                                size: 32,
                              ),
                      ),
                    );
                  },
                ),
              ),

              // Placeholder to maintain layout balance
              SizedBox(
                width: 56,
                height: 56,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildCameraPreview(),
          _buildTopControls(),
          _buildBottomControls(),
        ],
      ),
    );
  }
}

class CameraOverlayPainter extends CustomPainter {
  final Color color;

  CameraOverlayPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final rectHeight = size.height * 0.7;
    final rect = Rect.fromCenter(
      center: center,
      width: rectHeight * 0.75,
      height: rectHeight,
    );

    // Draw corner brackets
    final cornerLength = 20.0;

    // Top-left corner
    canvas.drawLine(
      Offset(rect.left, rect.top + cornerLength),
      Offset(rect.left, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLength, rect.top),
      paint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.top),
      Offset(rect.right, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLength),
      paint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(rect.left, rect.bottom - cornerLength),
      Offset(rect.left, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLength, rect.bottom),
      paint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.bottom),
      Offset(rect.right, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom - cornerLength),
      Offset(rect.right, rect.bottom),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}