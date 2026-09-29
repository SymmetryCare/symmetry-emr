import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';

class ChatSidebar extends StatelessWidget {
  const ChatSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      "General Help",
      "Product Inquiry",
      "Password Reset Request",
      "App Crashing Issue",
      "General Help",
      "Product Inquiry",
      "Password Reset Request",
      "App Crashing Issue",
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: AppPadding.p10,top: AppPadding.p10,bottom: AppPadding.p10),
        child: Container(
          decoration: BoxDecoration(
              color: const Color(0xFFFDF9F9),
              borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: AppPadding.p10,bottom:AppPadding.p20, left: AppPadding.p15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSize.s10,),
                Row(
                  children: [
                    Image.asset("images/communication/new_chat.png",height: 20,width: 20,),
                    const SizedBox(width: AppSize.s6),
                    Text("New Chat", style: TextStyle(fontSize: FontSize.s12, fontWeight: FontWeight.w600,color: ColorManager.mediumgrey)),
                  ],
                ),
                const SizedBox(height: AppSize.s10,),
                Row(
                  children: [
                    const Icon(Icons.search,size: IconSize.I20,color: Colors.grey,),
                    const SizedBox(width: AppSize.s8,),
                    Text("Search Chats", style: TextStyle(fontSize: FontSize.s12, fontWeight: FontWeight.w600,color: ColorManager.mediumgrey)),
                  ],
                ),
                const SizedBox(height: AppSize.s25),
                Text("Chats", style: TextStyle(fontSize: FontSize.s14, fontWeight: FontWeight.w600,color: ColorManager.faintGrey)),
                const SizedBox(height: AppSize.s10,),
                Expanded(
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: (){},
                            child: Text(categories[index],
                              style: TextStyle(fontSize: FontSize.s12, fontWeight: FontWeight.w600,color: ColorManager.mediumgrey),),
                          ),
                          const SizedBox(height: AppSize.s10,),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
