// class Productssss {
//   final int id;
//   final String name;
//   final String sector;
//   final String description;
//   final String imageUrl;

//   Productssss({
//     required this.id,
//     required this.name,
//     required this.sector,
//     required this.description,
//     required this.imageUrl,
//   });

//   @override
//   String toString() {
//     return 'Product{id: $id, name: $name, description: $description ,imageUrl:$imageUrl}';
//   }

//   // Manually created list of products
//   static List<Product> sampleProducts = [
//     Product(
//       id: 1,
//       name: 'Rice',
//       sector: 'Rice',
//       description:
//           'Premium quality long-grain rice, sustainably farmed with careful water management for optimal texture and nutrition',
//       imageUrl:
//           'https://thafd.bing.com/th/id/OIP.cvWZzHTCmAdsRMSgGWQXrwHaHa?w=185&h=185&c=7&r=0&o=7&cb=iwp1&dpr=1.3&pid=1.7&rm=3',
//     ),
//     Product(
//       id: 2,
//       name: 'Corn',
//       sector: 'Corn',
//       description:
//           'Sweet yellow corn grown with natural fertilizers, harvested at peak ripeness for maximum flavor and nutritional value',
//       imageUrl:
//           'https://tse4.mm.bing.net/th/id/OIP.gtgRbFm5Qf-EbDNjGHQ4GQHaF7?cb=iwp1&rs=1&pid=ImgDetMain',
//     ),
//     Product(
//       id: 3,
//       name: 'Tilapia',
//       sector: 'Fishery',
//       description:
//           'Freshwater tilapia raised in clean, controlled environments with sustainable feeding practices for firm, mild-flavored flesh',
//       imageUrl:
//           'https://www.balisafarimarinepark.com/wp-content/uploads/2022/11/tilapia-e1645622421681.jpg',
//     ),
//     Product(
//       id: 4,
//       name: 'Karpa',
//       sector: 'Fishery',
//       description:
//           'Fresh carp cultivated in freshwater ponds, known for its tender white meat and rich omega-3 fatty acid content',
//       imageUrl:
//           'https://thafd.bing.com/th/id/OIP.PpypTVC--BDyebIxgevHQwHaE8?w=221&h=180&c=7&r=0&o=7&cb=iwp1&dpr=1.3&pid=1.7&rm=3',
//     ),
//     Product(
//       id: 5,
//       name: 'Bangus',
//       sector: 'Fishery',
//       description:
//           'Premium milkfish (bangus) with distinctive flavor, raised in brackish water ponds using traditional aquaculture methods',
//       imageUrl:
//           'https://thafd.bing.com/th/id/OIP.rLnyzML7mMNJCdEB874LGQHaD4?w=285&h=180&c=7&r=0&o=7&cb=iwp1&dpr=1.3&pid=1.7&rm=3',
//     ),
//     Product(
//       id: 6,
//       name: 'Pangasius',
//       sector: 'Fishery',
//       description:
//           'Pangasius catfish farmed in carefully monitored river cages, producing lean, versatile fillets with consistent quality',
//       imageUrl: 'https://example.com/pangasius.jpg',
//     ),
//     Product(
//       id: 7,
//       name: 'Hammerhead',
//       sector: 'Fishery',
//       description:
//           'Sustainable hammerhead fish varieties harvested using responsible fishing methods to maintain ecological balance',
//       imageUrl: 'https://example.com/hammerhead.jpg',
//     ),
//     Product(
//       id: 8,
//       name: 'Cow',
//       sector: 'Livestock',
//       description:
//           'Grass-fed beef cattle raised in open pastures with humane treatment protocols for superior meat quality and marbling',
//       imageUrl:
//           'https://thafd.bing.com/th/id/OIP.E5U7VwqO02NhJUyd1nMDSAHaFl?w=247&h=185&c=7&r=0&o=7&cb=iwp1&dpr=1.3&pid=1.7&rm=3',
//     ),
//     Product(
//       id: 9,
//       name: 'Carabao',
//       sector: 'Livestock',
//       description:
//           'Water buffalo (carabao) raised for both dairy and meat production, known for leaner and more flavorful meat than beef',
//       imageUrl: 'https://example.com/carabao.jpg',
//     ),
//     Product(
//       id: 10,
//       name: 'Horse',
//       sector: 'Livestock',
//       description:
//           'Healthy horses bred for both riding and meat production, raised with ethical husbandry practices and proper nutrition',
//       imageUrl: 'https://example.com/horse.jpg',
//     ),
//     Product(
//       id: 11,
//       name: 'Goat',
//       sector: 'Livestock',
//       description:
//           'Free-range goats producing tender, flavorful meat with lower fat content than beef, raised without growth hormones',
//       imageUrl: 'https://example.com/goat.jpg',
//     ),
//     Product(
//       id: 12,
//       name: 'Sheep',
//       sector: 'Livestock',
//       description:
//           'Pasture-raised sheep yielding premium lamb and wool, managed with rotational grazing for sustainable land use',
//       imageUrl: 'https://example.com/sheep.jpg',
//     ),
//     Product(
//       id: 13,
//       name: 'Chicken',
//       sector: 'Livestock',
//       description:
//           'Free-range chickens raised without antibiotics, producing eggs and meat with richer flavor and better texture',
//       imageUrl:
//           'https://tse4.mm.bing.net/th/id/OIP.KpsJlSRWY8PESwWDZrvW6gHaE8?cb=iwp1&rs=1&pid=ImgDetMain',
//     ),
//     Product(
//       id: 14,
//       name: 'Pig',
//       sector: 'Livestock',
//       description:
//           'Heritage breed pigs raised in open-air pens for well-marbled pork with exceptional taste and juiciness',
//       imageUrl: 'https://example.com/pig.jpg',
//     ),
//     Product(
//       id: 15,
//       name: 'Boar',
//       sector: 'Livestock',
//       description:
//           'Wild boar meat with intense, gamey flavor, sustainably hunted or farm-raised in natural forest environments',
//       imageUrl: 'https://example.com/boar.jpg',
//     ),
//     Product(
//       id: 16,
//       name: 'Organic Vegetables',
//       sector: 'Organic',
//       description:
//           'Certified organic vegetables grown without synthetic pesticides or fertilizers for maximum nutrition and flavor',
//       imageUrl: 'https://example.com/organic.jpg',
//     ),
//     Product(
//       id: 17,
//       name: 'Mango',
//       sector: 'HVC',
//       description:
//           'Sweet Philippine mangoes (Carabao variety) hand-picked at perfect ripeness, known as the worlds best mango',
//       imageUrl:
//           'https://thafd.bing.com/th/id/OIP.dg4kmU8GvD02w3ZQfe1_7gHaEK?w=328&h=185&c=7&r=0&o=7&cb=iwp1&dpr=1.3&pid=1.7&rm=3',
//     ),
//     Product(
//       id: 18,
//       name: 'Ampalaya',
//       sector: 'HVC',
//       description:
//           'Fresh bitter melon (ampalaya) packed with nutrients and antioxidants, cultivated using integrated pest management',
//       imageUrl: 'https://example.com/ampalaya.jpg',
//     ),
//     Product(
//       id: 19,
//       name: 'Eggplant',
//       sector: 'HVC',
//       description:
//           'Vibrant purple eggplants grown in nutrient-rich soil, offering firm texture and mild flavor perfect for various dishes',
//       imageUrl: 'https://example.com/eggplant.jpg',
//     ),
//     Product(
//       id: 20,
//       name: 'Okra',
//       sector: 'HVC',
//       description:
//           'Tender okra pods harvested young for minimal sliminess, excellent for stews, stir-fries, and pickling',
//       imageUrl: 'https://example.com/okra.jpg',
//     ),
//     Product(
//       id: 21,
//       name: 'Squash',
//       sector: 'HVC',
//       description:
//           'Nutrient-dense squash varieties grown with natural compost, offering sweet flavor and versatile culinary uses',
//       imageUrl: 'https://example.com/squash.jpg',
//     ),
//     Product(
//       id: 22,
//       name: 'Sitao',
//       sector: 'HVC',
//       description:
//           'Tender string beans (sitao) hand-picked daily, grown vertically for straighter pods and better air circulation',
//       imageUrl: 'https://example.com/sitao.jpg',
//     ),
//     Product(
//       id: 23,
//       name: 'Tomato',
//       sector: 'HVC',
//       description:
//           'Vine-ripened tomatoes bursting with flavor, grown in full sunlight and harvested at peak redness for best quality',
//       imageUrl: 'https://example.com/tomato.jpg',
//     ),
//     Product(
//       id: 24,
//       name: 'Patola',
//       sector: 'HVC',
//       description:
//           'Young sponge gourd (patola) with delicate flavor and soft texture, ideal for soups and stir-fried dishes',
//       imageUrl: 'https://example.com/patola.jpg',
//     ),
//     Product(
//       id: 25,
//       name: 'Upo',
//       sector: 'HVC',
//       description:
//           'Fresh bottle gourd (upo) with mild, slightly sweet flavor and high water content, perfect for healthy recipes',
//       imageUrl: 'https://example.com/upo.jpg',
//     ),
//     Product(
//       id: 26,
//       name: 'Cucumber',
//       sector: 'HVC',
//       description:
//           'Crisp, refreshing cucumbers grown with trellising systems for straighter fruits and easier harvesting',
//       imageUrl:
//           'https://thafd.bing.com/th/id/OIP.tKQ3N9tqqJQvq7JaiJ8O9QHaEd?w=319&h=191&c=7&r=0&o=7&cb=iwp1&dpr=1.3&pid=1.7&rm=3',
//     ),
//   ];
// }
