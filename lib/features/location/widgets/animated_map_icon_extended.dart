import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';

class AnimatedMapIconExtended extends StatefulWidget {
  const AnimatedMapIconExtended({super.key});

  @override
  State<AnimatedMapIconExtended> createState() => _AnimatedMapIconExtendedState();
}

class _AnimatedMapIconExtendedState extends State<AnimatedMapIconExtended>  {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack( alignment: AlignmentDirectional.center, children: [
        Lottie.asset(Images.mapIconExtended , repeat: false, height: Dimensions.pickMapIconSize,
          delegates: LottieDelegates(
            values: [
              ValueDelegate.color(
                const ['Red circle Outlines', '**'],
                value: Theme.of(context).colorScheme.error,
              ),
              ValueDelegate.color(
                const ['Shape Layer 1', '**'],
                value: Theme.of(context).colorScheme.error,
              ),
              ValueDelegate.color(
                const ['Layer 4', 'Group 1', 'Stroke 1', '**'],
                value: Theme.of(context).colorScheme.error,
              ),
              ValueDelegate.color(
                const ['Layer 4', 'Group 2', 'Stroke 1', '**'],
                value: Theme.of(context).colorScheme.error,
              ),
              ValueDelegate.color(
                const ['Layer 4', 'Group 3', 'Stroke 1', '**'],
                value: Theme.of(context).colorScheme.error,
              ),
              ValueDelegate.color(
                const ['shadow Outlines', '**'],
                value: Theme.of(context).colorScheme.error,
              )
            ],
          ),

        ),
        Padding(
          padding:  const EdgeInsets.only(top: Dimensions.pickMapIconSize * 0.4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.end, mainAxisSize: MainAxisSize.min,
            children: List.generate(9, (index){
              return  Icon(Icons.circle, size: index == 8 ? Dimensions.pickMapIconSize * 0.06 : Dimensions.pickMapIconSize * 0.03,
                color: Theme.of(context).colorScheme.error,
              );
            }),
          ),
        ),
      ],),
    );
  }
}