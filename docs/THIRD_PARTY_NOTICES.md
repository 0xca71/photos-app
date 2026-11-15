# Third-party notices

## Depth Anything V2 (Small), Core ML conversion

The Spatial Scene feature uses the Depth Anything V2 Small model to estimate depth on the iPhone.
The app's release builds include it in compiled form; the source tree downloads it with
`Scripts/fetch-depth-model.sh`.

- Model: Depth Anything V2, by Lihe Yang, Bingyi Kang, Zilong Huang, Zhen Zhao, Xiaogang Xu, Jiashi Feng
  and Hengshuang Zhao. <https://github.com/DepthAnything/Depth-Anything-V2>
- Core ML conversion: <https://huggingface.co/apple/coreml-depth-anything-v2-small>
  (revision `cfef6f6f2a70783dedc0bfae40cecbc2052285d3`, file `DepthAnythingV2SmallF16.mlpackage`), unmodified.
- Licence: Apache License, Version 2.0. <https://www.apache.org/licenses/LICENSE-2.0>

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in
compliance with the License. Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
ANY KIND, either express or implied. See the License for the specific language governing permissions
and limitations under the License.
