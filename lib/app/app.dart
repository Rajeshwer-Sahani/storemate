import 'package:flutter/material.dart';
import 'package:storemate/app/theme/app_dimensions.dart';
import 'package:storemate/app/theme/app_theme.dart';

class StoreMateApp extends StatelessWidget {
  const StoreMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StoreMate',

      // StoreMate themes
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Temporary Design System preview
      home: const DesignSystemPreview(),
    );
  }
}

class DesignSystemPreview extends StatelessWidget {
  const DesignSystemPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('StoreMate Design System'),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenHorizontalPadding,
            vertical: AppDimensions.screenVerticalPadding,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Typography
              Text(
                'Typography',
                style: textTheme.headlineMedium,
              ),

              const SizedBox(
                height: AppDimensions.spacingLarge,
              ),

              Text(
                'Headline Large',
                style: textTheme.headlineLarge,
              ),

              const SizedBox(
                height: AppDimensions.spacingSmall,
              ),

              Text(
                'Headline Medium',
                style: textTheme.headlineMedium,
              ),

              const SizedBox(
                height: AppDimensions.spacingSmall,
              ),

              Text(
                'Headline Small',
                style: textTheme.headlineSmall,
              ),

              const SizedBox(
                height: AppDimensions.spacingMedium,
              ),

              Text(
                'Title Large',
                style: textTheme.titleLarge,
              ),

              const SizedBox(
                height: AppDimensions.spacingSmall,
              ),

              Text(
                'This is body text used for descriptions and regular content.',
                style: textTheme.bodyLarge,
              ),

              const SizedBox(
                height: AppDimensions.spacingXLarge,
              ),

              // Card
              Text(
                'Card',
                style: textTheme.titleLarge,
              ),

              const SizedBox(
                height: AppDimensions.spacingMedium,
              ),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(
                    AppDimensions.spacingMedium,
                  ),

                  child: Row(
                    children: [
                      Icon(
                        Icons.store_rounded,
                        color: colorScheme.primary,
                        size: AppDimensions.iconLarge,
                      ),

                      const SizedBox(
                        width: AppDimensions.spacingMedium,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'StoreMate',
                              style: textTheme.titleMedium,
                            ),

                            const SizedBox(
                              height: AppDimensions.spacingXSmall,
                            ),

                            Text(
                              'Manage your retail business efficiently.',
                              style: textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: AppDimensions.spacingXLarge,
              ),

              // Text field
              Text(
                'Input Field',
                style: textTheme.titleLarge,
              ),

              const SizedBox(
                height: AppDimensions.spacingMedium,
              ),

              const TextField(
                decoration: InputDecoration(
                  labelText: 'Email address',
                  hintText: 'Enter your email',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                  ),
                ),
              ),

              const SizedBox(
                height: AppDimensions.spacingXLarge,
              ),

              // Buttons
              Text(
                'Buttons',
                style: textTheme.titleLarge,
              ),

              const SizedBox(
                height: AppDimensions.spacingMedium,
              ),

              ElevatedButton(
                onPressed: () {},
                child: const Text('Primary Button'),
              ),

              const SizedBox(
                height: AppDimensions.spacingMedium,
              ),

              OutlinedButton(
                onPressed: () {},
                child: const Text('Secondary Button'),
              ),

              const SizedBox(
                height: AppDimensions.spacingSmall,
              ),

              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Text Button'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}