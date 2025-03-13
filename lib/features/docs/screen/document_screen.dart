import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:zenzen/config/app_colors.dart';
import 'package:zenzen/config/app_images.dart';
import 'package:zenzen/config/responsive.dart';
import 'package:zenzen/config/size_config.dart';
import 'package:zenzen/features/docs/widget/editor_widget.dart';
import 'package:zenzen/utils/theme.dart';

class NewDocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const NewDocumentScreen({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NewDocumentScreenState();
}

class _NewDocumentScreenState extends ConsumerState<NewDocumentScreen> {
  final TextEditingController _titleController =
      TextEditingController(text: 'Untitled Document');
  bool _isEmpty = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() {
      setState(() {
        _isEmpty = _titleController.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    // Calculate content width based on device type
    final contentWidth = Responsive.isDesktop(context)
        ? SizeConfig.screenWidth * 0.7
        : SizeConfig.screenWidth;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: SizedBox(
          height: SizeConfig.screenHeight,
          width: contentWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Material(
                elevation: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  height: SizeConfig.blockSizeVertical * 10,
                  width: SizeConfig.screenWidth,
                  color: AppColors.lightGrey,
                  child: Center(
                    child: Container(
                      width: contentWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Responsive.isMobile(context)
                                  ? Image.asset(
                                      AppImages.projectSmall,
                                    )
                                  : Image.asset(
                                      AppImages.projectLarge,
                                    ),
                              const Gap(20),
                              SizedBox(
                                width: Responsive.isMobile(context) ? 180 : 220,
                                child: TextField(
                                  style: AppTheme.textSmall(context),
                                  controller: _titleController,
                                  decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    enabledBorder: _isEmpty
                                        ? const OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.red,
                                            ),
                                          )
                                        : InputBorder.none,
                                    contentPadding:
                                        const EdgeInsets.only(left: 10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.all(20),
                            height: 80,
                            width: 120,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock,
                                  color: AppColors.white,
                                ),
                                const Gap(10),
                                AutoSizeText(
                                  'Share',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: contentWidth,
                    child: DocumentEditor(
                      documentId: '123',
                      onSave: (value) {},
                      initialContent: '',
                      key: Key('123'),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
