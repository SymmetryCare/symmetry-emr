import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_flow_contgainer_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_icon_button_constant.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/theme_manager.dart' show CustomTextStylesCommon;
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/textfield_dropdown_constant/schedular_textfield_const.dart';

class ContactEFaxScreen extends StatelessWidget {
  const ContactEFaxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 20,left: 15,right: 15,bottom: 10),
          child: Container(
              decoration: BoxDecoration(
                color: ColorManager.white,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8)),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade300,
                    width: 3,
                  ),
                  left: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                  right: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8)),
                  border: Border(
                      top: BorderSide(color: Color(0xFF1696C8),width: 5)
                  ),
                ),
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    width: 320,
                    decoration: BoxDecoration(
                      color: ColorManager.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10,bottom: 3,),
                      child: TabBar(
                        labelColor: Colors.white,
                        unselectedLabelColor:  ColorManager.textPrimaryColor,
                        indicatorPadding:  const EdgeInsets.symmetric(horizontal: 15,vertical: 1),
                        indicator: BoxDecoration(
                          color: ColorManager.SMFBlue,
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                        ),
                        tabs: [
                          Tab(child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                           spacing: 5,
                            children: [
                              Flexible(child: Icon(Icons.fax_rounded,size: 30,color:  ColorManager.textPrimaryColor,)),
                              Flexible(child: Text("Send Fax",  style: CustomTextStylesCommon.commonStyle(fontSize: FontSize.s14,
                                fontWeight: FontWeight.w700,
                                color:  ColorManager.textPrimaryColor,),))
                            ],
                          ),),
                          Tab(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 10,
                              children: [
                                Flexible(child: Icon(Icons.history,color:  ColorManager.textPrimaryColor,)),
                                Flexible(child: Text("History",  style: CustomTextStylesCommon.commonStyle(fontSize: FontSize.s14,
                                  fontWeight: FontWeight.w700,
                                  color:  ColorManager.textPrimaryColor,),))
                              ],
                            ),),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(),
                  ),
                  const Expanded(
                    child: TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        SendFaxTab(),
                        FaxHistoryTab()
                      ],
                    ),
                  ),
                ],
              ),
          ), )
        )
        )
    );
  }
}
/// send fax
class SendFaxTab extends StatelessWidget {
  const SendFaxTab({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController companyController = TextEditingController();
    TextEditingController faxController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController typeTextController = TextEditingController();
    return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
    child:SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height:0),
            Text('Receiver Information',style: CustomTextStylesCommon.commonStyle(
              color:const Color(0xFF686464),
              fontWeight: FontWeight.w400,fontSize: 14,
            ),),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                height: AppSize.s150,
                decoration: BoxDecoration(
                  color: ColorManager.white,
                  border: Border(
                    bottom: BorderSide(width: 0.5,color: ColorManager.lightGrey),
                  ),
                ),
                child: Column(
                  spacing: 16,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: SchedularTextField(
                            controller: nameController,
                            labelText: 'Name',
                            isIconVisible: true,
                          ),
                        ),
                       const SizedBox(width: 50,),
                        Flexible(
                          child: SchedularTextField(
                            controller: companyController,
                            labelText: 'Company',
                            isIconVisible: true,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: SchedularTextField(
                            controller: faxController,
                            labelText: 'Fax',
                            isIconVisible: true,
                              onlyAllowNumbers: true,
                          ),
                        ),
                        const SizedBox(width: 50,),
                        Flexible(
                          child: SchedularTextField(
                            controller: phoneController,
                            labelText: 'Phone',
                            isIconVisible: true,
                            phoneField: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),),
            ),
            const SizedBox(height:20),
            Row(
              children: [
                CustomIconButtonConst(
                 color:    ColorManager.blueprime,
                  height: 35,
                    width: 140,
                    text: 'Upload files',
                    icon: Icons.file_upload_outlined,
                    onPressed: () {

                    }),
const SizedBox(width: 40,),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color(
                            0xffB1B1B1)),
                    borderRadius:
                    BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding:
                    const EdgeInsets
                        .all(8.0),
                    child: Text(
                      'No file chosen'
                        ,style: CustomTextStylesCommon.commonStyle(
                    color:const Color(0xFF686464),
                    fontWeight: FontWeight.w400,fontSize: 12,
                  ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height:20),
            SchedularTextField(
              width: double.maxFinite,
              controller: typeTextController,
              labelText: 'Type text here',
              isIconVisible: true,
            ),
            const SizedBox(height:60),
            Align(
              alignment: Alignment.bottomCenter,
              child: CustomElevatedButton(
                color:  ColorManager.blueprime,
                width: AppSize.s100,
                text:"Send",
                onPressed: (){},
              ),
            ),
            const SizedBox(height:40),
          ],
        ),
      ),
    ),
    );
  }
}

/// Fax history
class FaxHistoryTab extends StatelessWidget {
  const FaxHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 1.5,
              child: ListView.builder(
                itemCount: 8,
                  itemBuilder: (BuildContext, index){
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 25,
                          children: [
                            Column(
                              children: [
                                Image.asset("images/sm/file.png",height: 20,),
                              ],
                            ),
                            SizedBox(
                              width: 200,
                              child: Text('eFax sent by Warren. No document attached.',
                                  style:CustomTextStylesCommon.commonStyle(fontSize: FontSize.s12,
                                    fontWeight: FontWeight.w500,
                                    color: ColorManager.mediumgrey,),),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('2024/08/05',style: CustomTextStylesCommon.commonStyle(
                                color:const Color(0xFF686464),
                                fontWeight: FontWeight.w400,fontSize: 12,
                              ),),
                              Text('8:17PM',style: CustomTextStylesCommon.commonStyle(
                                color:const Color(0xFF686464),
                                fontWeight: FontWeight.w400,fontSize: 12,
                              ),),
                            ],
                          ),
                        )
                    
                      ],
                    ),
                  );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

