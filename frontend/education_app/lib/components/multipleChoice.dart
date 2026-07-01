import 'package:flutter/material.dart';

//want to make this less exact, so i can use it again
class MultipleChoice extends StatefulWidget {
  // final List<List<int>> options; //choices of options
  final int
  correctPostion; //position of right answer //could change these into a function?

  final Widget Function(int index) displayOptions;
  final Function(bool correct) onResult; //on result function

  const MultipleChoice({
    super.key,
    required this.displayOptions,
    required this.correctPostion,
    required this.onResult,
  });

  @override
  State<MultipleChoice> createState() => MultipleChoiceState();
}

class MultipleChoiceState extends State<MultipleChoice> {
  int? selectedIndex; //int or NULL
  bool confirmed = false;

  void onTap(int index) {
    if (confirmed) return;
    setState(() {
      selectedIndex = index;
    });
  }

  void onConfirm() {
    if (selectedIndex == null) return; //Nothing selected yet
    setState(() {
      confirmed = true;
    });
    widget.onResult(selectedIndex == widget.correctPostion);
  }

  Color getBorderColor(int index) {
    if (!confirmed) {
      return selectedIndex == index
          ? Colors.blue
          : Colors
                .grey; //First is the widget selected? if yes make it blue, else gret
    }
    if (index == widget.correctPostion) return Colors.green;
    if (index == selectedIndex) return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    confirmed = false;
    return Column(
      children: [
        //need to create 4 boxes
        ...List.generate(
          4,
          (i) => GestureDetector(
            //Create 4 gesture detectors with index i, ... makes it not a list of lists
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 120,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: getBorderColor(i), width: 2),
                borderRadius: BorderRadius.circular(12),
                color: selectedIndex == i
                    ? Colors.lightBlue.shade100
                    : Colors.transparent,
              ),
              child: SizedBox(
                height: 36,
                width: 200,
                child: widget.displayOptions(
                  i,
                ), //this is the main line that needs to
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        ElevatedButton(
          onPressed: selectedIndex != null && !confirmed ? onConfirm : null,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
