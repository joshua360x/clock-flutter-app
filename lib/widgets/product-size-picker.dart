import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:material_kit_pro_flutter/constants/Theme.dart';

class ProductSizePicker extends StatefulWidget {
  @override
  _ProductSizePickerState createState() => _ProductSizePickerState();
}

class _ProductSizePickerState extends State<ProductSizePicker> {
  String isSelected = "0";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isSelected = "XS";
                    });
                  },
                  child: Container(
                      padding: EdgeInsets.only(top: 16, bottom: 16),
                      decoration: BoxDecoration(
                          color: isSelected == "XS"
                              ? MaterialColors.priceColor
                              : Colors.transparent,
                          border: Border(
                            top: BorderSide(
                                color: MaterialColors.border, width: 0.5),
                            left: BorderSide(
                                color: MaterialColors.border, width: 0.5),
                            right: BorderSide(
                                color: MaterialColors.border, width: 0.5),
                            bottom: BorderSide(
                                color: MaterialColors.border, width: 0.5),
                          ),
                          borderRadius:
                              BorderRadius.only(topLeft: Radius.circular(4.0))),
                      child: Center(
                        child: Text("XS",
                            style: TextStyle(
                                color: isSelected == "XS"
                                    ? MaterialColors.primary
                                    : Colors.black,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500)),
                      )),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isSelected = "S";
                    });
                  },
                  child: Container(
                      padding: EdgeInsets.only(
                        top: 16,
                        bottom: 16,
                      ),
                      decoration: BoxDecoration(
                          color: isSelected == "S"
                              ? MaterialColors.priceColor
                              : Colors.transparent,
                          border: Border(
                            top: BorderSide(
                                color: MaterialColors.border, width: 0.5),
                            bottom: BorderSide(
                                color: MaterialColors.border, width: 0.5),
                          )),
                      child: Center(
                        child: Text("S",
                            style: TextStyle(
                                color: isSelected == "S"
                                    ? MaterialColors.primary
                                    : Colors.black,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500)),
                      )),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isSelected = "M";
                    });
                  },
                  child: Container(
                      padding: EdgeInsets.only(
                        top: 16,
                        bottom: 16,
                      ),
                      decoration: BoxDecoration(
                          color: isSelected == "M"
                              ? MaterialColors.priceColor
                              : Colors.transparent,
                          border: Border(
                            top: BorderSide(
                                color: MaterialColors.border, width: 0.5),
                            left: BorderSide(
                                color: MaterialColors.border, width: 0.5),
                            right: BorderSide(
                                color: MaterialColors.border, width: 0.5),
                            bottom: BorderSide(
                                color: MaterialColors.border, width: 0.5),
                          ),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(4.0))),
                      child: Center(
                        child: Text("M",
                            style: TextStyle(
                                color: isSelected == "M"
                                    ? MaterialColors.primary
                                    : Colors.black,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500)),
                      )),
                ),
              )
            ],
          ),
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isSelected = "L";
                  });
                },
                child: Container(
                    padding: EdgeInsets.only(top: 16, bottom: 16),
                    decoration: BoxDecoration(
                        color: isSelected == "L"
                            ? MaterialColors.priceColor
                            : Colors.transparent,
                        border: Border(
                          top: BorderSide(
                              color: MaterialColors.border, width: 0.5),
                          left: BorderSide(
                              color: MaterialColors.border, width: 0.5),
                          right: BorderSide(
                              color: MaterialColors.border, width: 0.5),
                          bottom: BorderSide(
                              color: MaterialColors.border, width: 0.5),
                        ),
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(4.0))),
                    child: Center(
                      child: Text("L",
                          style: TextStyle(
                              color: isSelected == "L"
                                  ? MaterialColors.primary
                                  : Colors.black,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500)),
                    )),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isSelected = "XL";
                  });
                },
                child: Container(
                    padding: EdgeInsets.only(
                      top: 16,
                      bottom: 16,
                    ),
                    decoration: BoxDecoration(
                        color: isSelected == "XL"
                            ? MaterialColors.priceColor
                            : Colors.transparent,
                        border: Border(
                          top: BorderSide(
                              color: MaterialColors.border, width: 0.5),
                          bottom: BorderSide(
                              color: MaterialColors.border, width: 0.5),
                        )),
                    child: Center(
                      child: Text("XL",
                          style: TextStyle(
                              color: isSelected == "XL"
                                  ? MaterialColors.primary
                                  : Colors.black,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500)),
                    )),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isSelected = "2XL";
                  });
                },
                child: Container(
                    padding: EdgeInsets.only(
                      top: 16,
                      bottom: 16,
                    ),
                    decoration: BoxDecoration(
                        color: isSelected == "2XL"
                            ? MaterialColors.priceColor
                            : Colors.transparent,
                        border: Border(
                          top: BorderSide(
                              color: MaterialColors.border, width: 0.5),
                          left: BorderSide(
                              color: MaterialColors.border, width: 0.5),
                          right: BorderSide(
                              color: MaterialColors.border, width: 0.5),
                          bottom: BorderSide(
                              color: MaterialColors.border, width: 0.5),
                        ),
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(4.0))),
                    child: Center(
                      child: Text("2XL",
                          style: TextStyle(
                              color: isSelected == "2XL"
                                  ? MaterialColors.primary
                                  : Colors.black,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500)),
                    )),
              ),
            )
          ])
        ],
      ),
    );
  }
}
