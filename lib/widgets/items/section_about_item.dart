import 'package:flutter/material.dart';
import 'package:knocklock_flutter/core/colors.dart';

class Section extends StatelessWidget {
  final String title;
  final String? content;
  final List<String>? items;

  const Section({
    super.key,
    required this.title,
    this.content,
    this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.thirdColor, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: title),
          if (content != null) SectionContent(content: content!),
          if (items != null) SectionListContent(items: items!),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 25.0, bottom: 8.0),
      child: Text(
        title,
        style: AppTextStyles.sectionAboutTitleTextStyle,
      ),
    );
  }
}

class SectionContent extends StatelessWidget {
  final String content;

  const SectionContent({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      style: AppTextStyles.sectionAboutContentTextStyle,
    );
  }
}

class SectionListContent extends StatelessWidget {
  final List<String> items;

  const SectionListContent({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 16)),
              Expanded(
                child: Text(
                  item,
                  style: AppTextStyles.sectionAboutContentTextStyle,
                ),
              ),
            ],
          ),
        ),
      )
          .toList(),
    );
  }
}